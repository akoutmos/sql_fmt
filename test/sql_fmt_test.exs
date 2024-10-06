defmodule SqlFmtTest do
  use ExUnit.Case

  describe "SqlFmt.format_query/2" do
    test "should format the query with default formatting options" do
      assert {:ok, result} = SqlFmt.format_query("select * from hello_world;")

      assert String.trim("""
             SELECT
               *
             FROM
               hello_world;
             """) == result
    end

    test "should format the query with custom formatting options" do
      assert {:ok, result} = SqlFmt.format_query("select * from hello_world;", indent: 4, uppercase: false)

      assert String.trim("""
             select
                 *
             from
                 hello_world;
             """) == result

      assert {:ok, result} =
               SqlFmt.format_query("select * from hello_world;", indent: 4, ignore_case_convert: ["select"])

      assert String.trim("""
             select
                 *
             FROM
                 hello_world;
             """) == result
    end
  end
end
