defmodule Mix.Tasks.SqlFmt.Format do
  @shortdoc "Formats the given SQL files"

  @moduledoc """
  Formats the given files and patterns.

      $ mix sql_fmt.format query.sql "sql/**/*.sql"

  ## Options

  The following CLI options are supported:

  * `--check-formatted` - checks that the file is already formatted.
    This is useful in pre-commit hooks and CI scripts if you want to
    reject contributions with unformatted SQL code. If the check fails,
    the formatted contents are not written to disk.

  * `--indent` – specifies how many spaces are used for indents.
    Defaults to `2`.

  * `--no-uppercase` – if set SQL reserved words will not be capitalized.

  * `--lines-between-queries` – specifies how many line breaks should be
    present after a query. Defaults to `1`.

  * `--ignore-case-convert` – comma separated list of strings that should
    not be case converted. If not set all reserved keywords are capitalized.
  """

  use Mix.Task

  @switches [
    check_formatted: :boolean,
    indent: :integer,
    no_uppercase: :boolean,
    lines_between_queries: :integer,
    ignore_case_convert: :string
  ]

  @impl true
  def run(args) do
    {opts, paths} = OptionParser.parse!(args, strict: @switches)

    files = expand_paths(paths)

    files
    |> Task.async_stream(&format_file(&1, opts), ordered: false, timeout: :infinity)
    |> Enum.reduce({[], []}, &collect_status/2)
    |> check!()
  end

  defp parse_ignore_case_convert(nil), do: []
  defp parse_ignore_case_convert(ignore), do: String.split(ignore, ",")

  defp expand_paths([]) do
    Mix.raise("Expected one or more files/patterns to be given to mix sql_fmt.format")
  end

  defp expand_paths(files_and_patterns) do
    files =
      for file_or_pattern <- files_and_patterns,
          file <- matching_files(file_or_pattern),
          uniq: true,
          do: file

    if files == [] do
      Mix.raise(
        "Could not find a file to format. The files/patterns given to command line " <>
          "did not point to any existing file. Got: #{inspect(files_and_patterns)}"
      )
    end

    files
  end

  defp matching_files(path) do
    path
    |> Path.expand()
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
  end

  defp format_file(file, opts) do
    input = File.read!(file)

    formatter_opts = [
      indent: opts[:indent] || 2,
      uppercase: !opts[:no_uppercase],
      lines_between_queries: opts[:lines_between_queries] || 1,
      ignore_case_convert: parse_ignore_case_convert(opts[:ignore_case_convert])
    ]

    {:ok, output} = SqlFmt.format_query(input, formatter_opts)

    check_formatted? = Keyword.get(opts, :check_formatted, false)

    cond do
      check_formatted? ->
        if input == output, do: :ok, else: {:not_formatted, {file, input, output}}

      true ->
        File.write!(file, output)
    end
  rescue
    exception ->
      {:exit, file, exception, __STACKTRACE__}
  end

  defp collect_status({:ok, :ok}, acc), do: acc

  defp collect_status({:ok, {:exit, _, _, _} = exit}, {exits, not_formatted}) do
    {[exit | exits], not_formatted}
  end

  defp collect_status({:ok, {:not_formatted, file}}, {exits, not_formatted}) do
    {exits, [file | not_formatted]}
  end

  defp check!({[], []}), do: :ok

  defp check!({[{:exit, file, exception, stacktrace} | _], _not_formatted}) do
    Mix.shell().error("mix sql_fmt.format failed for file: #{Path.relative_to_cwd(file)}")
    reraise exception, stacktrace
  end

  defp check!({_exits, [_ | _] = not_formatted}) do
    files =
      Enum.map(not_formatted, fn {file, _input, _output} ->
        file = Path.relative_to_cwd(file, force: true)

        [
          IO.ANSI.bright(),
          IO.ANSI.red(),
          "* ",
          file,
          IO.ANSI.reset()
        ]
      end)
      |> Enum.join("\n")

    message = """
    The following files are not formatted:

    #{files}
    """

    Mix.raise("""
    mix sql_fmt.format failed due to --check-formatted.
    #{message}
    """)
  end
end
