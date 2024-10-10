defmodule SqlFmt do
  @moduledoc """
  This library provides an Elixir wrapper around the Rust
  [sqlformat](https://github.com/shssoichiro/sqlformat-rs) library. This allows you
  to efficiently format and pretty print SQL queries.
  """

  alias SqlFmt.FormatOptions
  alias SqlFmt.Native

  @doc """
  This function takes a query as a string along with optional formatting
  settings and returns the formatted query.

  For formatting settings look at the `SqlFmt.FormatOptions` module docs.
  """
  @spec format_query(query :: String.t()) :: {:ok, String.t()}
  @spec format_query(query :: String.t(), fmt_opts :: keyword()) :: {:ok, String.t()}
  def format_query(query, fmt_opts \\ []) do
    format_options = FormatOptions.new(fmt_opts)

    query
    |> Native.format(format_options)
    |> maybe_clean_special_character_operators()
  end

  @doc """
  This function takes a query as a string along with its parameters as a list of strings
  and optional formatting settings and returns the formatted query. As a note, when using this
  function all of the element in `query_params` must be strings and they all must be
  extrapolated out to their appropriate SQL values. For example query params of `["my_id"]`
  should be `["'my_id'"]` so that it is valid SQL when the parameter substitution takes place.

  For formatting settings look at the `SqlFmt.FormatOptions` module docs.
  """
  @spec format_query_with_params(query :: String.t(), query_params :: list(String.t())) :: {:ok, String.t()}
  @spec format_query_with_params(query :: String.t(), query_params :: list(String.t()), fmt_opts :: keyword()) ::
          {:ok, String.t()}
  def format_query_with_params(query, query_params, fmt_opts \\ []) do
    format_options = FormatOptions.new(fmt_opts)

    query
    |> Native.format(query_params, format_options)
    |> maybe_clean_special_character_operators()
  end

  # ---- Private helper functions ----

  @special_character_sequence_regex ~r/(\+|\-|\*|\/|\<|\>|\=|\~|\!|\@|\#|\%|\^|\&|\||\`|\?)\s(\+|\-|\*|\/|\<|\>|\=|\~|\!|\@|\#|\%|\^|\&|\||\`|\?)/

  # This is a work around the following bug in the Rust formatting
  # library https://github.com/shssoichiro/sqlformat-rs/issues/52
  #
  # 63 Regex replacement passes has been chosen as it is the default max
  # operator name as per the Postgres docs https://www.postgresql.org/docs/current/sql-createoperator.html.
  # The function will break early if no more replacements need to occur though.
  defp maybe_clean_special_character_operators({:ok, formatted_query}) do
    post_processed_query =
      1..63
      |> Enum.reduce_while(formatted_query, fn _pass, acc ->
        new_string = Regex.replace(@special_character_sequence_regex, acc, "\\g{1}\\g{2}")

        if acc == new_string do
          {:halt, new_string}
        else
          {:cont, new_string}
        end
      end)

    {:ok, post_processed_query}
  end

  defp maybe_clean_special_character_operators(other) do
    other
  end
end
