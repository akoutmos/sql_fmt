defmodule SqlFmt.HelpersTest do
  use ExUnit.Case

  import Ecto.Query
  import SqlFmt.Helpers

  test "sigil_SQL" do
    assert ~SQL"SELECT *" == "SELECT *"

    assert ~SQL"""
           SELECT *
           FROM users
           """ ==
             """
             SELECT *
             FROM users
             """

    assert from("my_table", select: fragment(~SQL"? > ?", 2, 1))
    assert from("my_table", select: fragment(~SQL"now()"))
  end
end
