defmodule SqlFmt.HelpersTest do
  use ExUnit.Case
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
  end
end
