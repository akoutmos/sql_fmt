defmodule SqlFmtTest do
  use ExUnit.Case

  describe "SqlFmt.format_query/2" do
    test "should format the query" do
      assert {:ok, result} = SqlFmt.format_query("select * from hello_world;")

      assert String.trim("""
             SELECT
               *
             FROM
               hello_world;
             """) == result
    end
  end
end
