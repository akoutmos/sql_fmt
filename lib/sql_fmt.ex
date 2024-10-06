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
    Native.format(query, format_options)
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

    Native.format(query, query_params, format_options)
  end
end
