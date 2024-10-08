defmodule SqlFmt.Formatter do
  @moduledoc """
  Format SQL queries from `.sql` files or `~SQL` sigils.

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
  queries or inline `~SQL` sigils.

  > #### Single line `~SQL` sigils {: .info}
  >
  > Notice that if an `~SQL` sigil with a single delimiter is used then this is
  > respected and only the reserved keyowrds are capitalized. For example:
  >
  > ```elixir
  > query = ~SQL"select * from users"
  > ```
  >
  > would be formatted as:
  >
  > ```elixir
  > query = ~SQL"SELECT * FROM users"
  > ```
  """
  @behaviour Mix.Tasks.Format

  @impl Mix.Tasks.Format
  def features(opts) do
    extensions = get_in(opts, [:sql_fmt, :extensions]) || [".sql"]
    [sigils: [:SQL], extensions: extensions]
  end

  @impl Mix.Tasks.Format
  def format(source, opts) do
    formatter_opts =
      opts
      |> Keyword.get(:sql_fmt, [])
      |> Keyword.drop([:extensions])
      |> Keyword.validate!(indent: 2, uppercase: true, lines_between_queries: 1, ignore_case_convert: [])

    {:ok, formatted} = SqlFmt.format_query(source, formatter_opts)

    # we need some special handling for the sigils:
    #
    # - If we are handling an SQL sigil and the opening delimiter is a single
    # character we should not add a trailing line
    # - If the sigil's optening delimiter is a single character we need
    # to remove all newlines introduced by the formatter

    formatted =
      formatted
      |> maybe_remove_newlines(opts[:sigil], opts[:opening_delimiter])
      |> maybe_add_newline(opts[:sigil], opts[:opening_delimiter])

    formatted
  end

  defp maybe_remove_newlines(query, :SQL, <<_>>), do: String.replace(query, ~r/\s+/, " ") |> String.trim()
  defp maybe_remove_newlines(query, _, _), do: query

  defp maybe_add_newline(query, :SQL, <<_, _, _>>), do: query <> "\n"
  defp maybe_add_newline(query, _, _), do: query
end
