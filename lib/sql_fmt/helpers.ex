defmodule SqlFmt.Helpers do
  @moduledoc """
  The `~SQL` sigil.

  You can wrap your inline sql queries with the `~SQL` sigil and the formatter
  will format them using the `SqlFmt.format_query/2` function.
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
