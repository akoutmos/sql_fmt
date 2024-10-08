defmodule SqlFmt.Formatter do
  @moduledoc """
  Format SQL queries from `.sql` files.

  This is a `mix format` [plugin](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html#module-plugins).

  ## Setup

  Add it as a plugin to your `.formatter.exs` file. If you want it to run automatically for
  all your project's `sql` files make sure to put the proper pattern in the `inputs` option.

  ```elixir
  [
    plugins: [SqlFmt.Formatter],
    inputs: ["**/*.sql"],
    # ...
  ]
  ```

  ## Options

  The following options are supported. You should specify them under a `:sql_fmt` key in
  your `.formatter.exs`.

    * `:indent` - specifies how many spaces are used for indents. Defaults to `2`.

    * `:uppercase` - specifies if the SQL reserved words will be capitalized. Defaults
      to `true`.

    * `:lines_between_queries` - specifies how many line breaks should be
      present after a query. Applicable only for input containing multiple queries.
      Defaults to `1`.

    * `:ignore_case_convert` - comma separated list of strings that should
      not be case converted. If not set all reserved keywords are capitalized.

    * `:extensions` - change the default file extensions to be considered. Defaults to
      `[".sql"]`

  An example configuration object with all supported options set follows.

      [
        # ...omitted
        sql_fmt: [
          indent: 4,
          uppercase: true,
          lines_between_queries: 2,
          ignore_case_convert: ["where", "into"],
          extensions: [".sql", ".query"]
        ]
      ]

  ## Formatting

  The formatter uses `SqlFmt.format_query/2` in order to format the input `SQL`
  queries.
  """
  @behaviour Mix.Tasks.Format

  @impl Mix.Tasks.Format
  def features(opts) do
    extensions = get_in(opts, [:sql_fmt, :extensions]) || [".sql"]
    [extensions: extensions]
  end

  @impl Mix.Tasks.Format
  def format(source, opts) do
    formatter_opts =
      opts
      |> Keyword.get(:sql_fmt, [])
      |> Keyword.drop([:extensions])
      |> Keyword.validate!(indent: 2, uppercase: true, lines_between_queries: 1, ignore_case_convert: [])

    {:ok, formatted} = SqlFmt.format_query(source, formatter_opts)

    formatted
  end
end
