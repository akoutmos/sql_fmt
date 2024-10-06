defmodule SqlFmt do
  @moduledoc """
  This library provides an Elixir wrapper around the Rust
  [sqlformat](https://github.com/shssoichiro/sqlformat-rs) library. This allows you
  to efficiently format and pretty print SQL queries.
  """

  alias SqlFmt.FormatOptions
  alias SqlFmt.Native

  def format_query(query, fmt_opts \\ []) do
    format_options = FormatOptions.new(fmt_opts)
    Native.format(query, format_options)
  end

  # def format_query_with_params(query, query_params, fmt_opts \\ []) do
  #   format_options = FormatOptions.new(fmt_opts)
  #   Native.format(query, query_params, format_options)
  # end
end
