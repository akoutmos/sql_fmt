defmodule SqlFmt.Helpers do
  @moduledoc ~S"""
  This module contains the `~SQL` sigil implementation.

  You can wrap your inline sql queries with the `~SQL` sigil and the formatter
  will format them using the `SqlFmt.format_query/2` function.

  > #### Sigil Caveats {: .tip}
  >
  > Sigils with capitalized letters do not interpolate strings. So your `~SQL`
  > queries must be complete queries without any `#{...}` entries as those will
  > not be expanded [Elixir Docs](https://hexdocs.pm/elixir/1.12/Macro.html#module-custom-sigils).
  """

  @doc """
  Indicates that a string is an SQL query.

  This is currently used only by the `SqlFmt.MixFormatter` `mix format` plugin
  for formatting inling `SQL` in your elixir code.
  """
  def sigil_SQL(query, _modifiers) do
    query
  end
end
