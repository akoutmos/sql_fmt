defmodule Mix.Tasks.SqlFmt.FormatTest do
  use ExUnit.Case, async: true

  test "formats matching files", context do
    in_tmp(context.test, fn ->
      sql_fixture("query.sql")

      Mix.Tasks.SqlFmt.Format.run(["query.sql"])
      assert File.read!("query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "with --indent set", context do
    in_tmp(context.test, fn ->
      sql_fixture("query.sql")

      Mix.Tasks.SqlFmt.Format.run(["query.sql", "--indent", "4"])
      assert File.read!("query.sql") == "SELECT\n    *\nFROM\n    users"
    end)
  end

  test "with --no-uppercase set", context do
    in_tmp(context.test, fn ->
      sql_fixture("query.sql")

      Mix.Tasks.SqlFmt.Format.run(["query.sql", "--no-uppercase"])
      assert File.read!("query.sql") == "select\n  *\nfrom\n  users"
    end)
  end

  test "with multiple queries", context do
    in_tmp(context.test, fn ->
      content = "select * from users; select * from groups;"
      sql_fixture("query.sql", content)

      Mix.Tasks.SqlFmt.Format.run(["query.sql"])

      assert File.read!("query.sql") ==
               """
               SELECT
                 *
               FROM
                 users;
               SELECT
                 *
               FROM
                 groups;\
               """

      # with --lines-between-queries set
      Mix.Tasks.SqlFmt.Format.run(["query.sql", "--lines-between-queries", "3"])

      assert File.read!("query.sql") ==
               """
               SELECT
                 *
               FROM
                 users;


               SELECT
                 *
               FROM
                 groups;\
               """
    end)
  end

  test "with --ignore-case-convert set", context do
    in_tmp(context.test, fn ->
      sql_fixture("query.sql", "select * from users where age > 18;")

      Mix.Tasks.SqlFmt.Format.run(["query.sql", "--ignore-case-convert", "select,where"])
      assert File.read!("query.sql") == "select\n  *\nFROM\n  users\nwhere\n  age > 18;"

      Mix.Tasks.SqlFmt.Format.run(["query.sql", "--ignore-case-convert", "select"])
      assert File.read!("query.sql") == "select\n  *\nFROM\n  users\nWHERE\n  age > 18;"
    end)
  end

  test "with wildcards and multiple patterns", context do
    in_tmp(context.test, fn ->
      sql_fixture("sql/path_a/query.sql")
      sql_fixture("sql/path_a/query2.sql")
      sql_fixture("sql/path_b/query.sql")
      sql_fixture("queries/query.sql")

      Mix.Tasks.SqlFmt.Format.run(["sql/**/*.sql", "queries/query.sql"])
      assert File.read!("sql/path_a/query.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("sql/path_a/query2.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("sql/path_b/query.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("queries/query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "checks if file is formatted with --check-formatted", context do
    in_tmp(context.test, fn ->
      sql_fixture("query.sql")

      assert_raise Mix.Error, ~r"mix sql_fmt.format failed due to --check-formatted", fn ->
        Mix.Tasks.SqlFmt.Format.run(["query.sql", "--check-formatted"])
      end

      # the file has not changed
      assert File.read!("query.sql") == "select * from users"

      # format it and run with --check-formatted again
      assert Mix.Tasks.SqlFmt.Format.run(["query.sql"]) == :ok
      assert Mix.Tasks.SqlFmt.Format.run(["query.sql", "--check-formatted"]) == :ok

      assert File.read!("query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "raises on invalid arguments", context do
    in_tmp(context.test, fn ->
      assert_raise Mix.Error, ~r"Expected one or more files\/patterns to be given", fn ->
        Mix.Tasks.SqlFmt.Format.run([])
      end

      assert_raise Mix.Error, ~r"Could not find a file to format", fn ->
        Mix.Tasks.SqlFmt.Format.run(["unknown.whatever"])
      end
    end)
  end

  test "raises for invalid files", context do
    in_tmp(context.test, fn ->
      # create a corrupt file to make it fail 
      sql_fixture("query.sql", <<255, 255>>)

      assert_raise ArgumentError, fn ->
        Mix.Tasks.SqlFmt.Format.run(["*.sql"])
      end

      assert_received {:mix_shell, :error, ["mix sql_fmt.format failed for file: query.sql"]}
    end)
  end

  def in_tmp(which, function) do
    path = tmp_path(which)
    File.rm_rf!(path)
    File.mkdir_p!(path)
    File.cd!(path, function)
  end

  defp tmp_path(path), do: Path.join("../tmp", remove_colons(path)) |> Path.expand()

  defp remove_colons(term) do
    term
    |> to_string()
    |> String.replace(":", "")
  end

  defp sql_fixture(path, query \\ "select * from users") do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, query)
  end
end
