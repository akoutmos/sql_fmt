defmodule SqlFmt.FormatterTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Format

  test "formats matching files", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter])
      sql_fixture("query.sql")

      Format.run(["query.sql"])
      assert File.read!("query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "with :indent option set", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [indent: 4])
      sql_fixture("query.sql")

      Format.run(["query.sql"])
      assert File.read!("query.sql") == "SELECT\n    *\nFROM\n    users"
    end)
  end

  test "with :uppercase set to false", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [uppercase: false])
      sql_fixture("query.sql")

      Format.run(["query.sql"])
      assert File.read!("query.sql") == "select\n  *\nfrom\n  users"
    end)
  end

  test "with multiple queries", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter])
      content = "select * from users; select * from groups;"
      sql_fixture("query.sql", content)

      Format.run(["query.sql"])

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

      # with :lines-between-queries set to a different value
      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [lines_between_queries: 2])
      Format.run(["query.sql"])

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

  test "with :ignore-case-convert set", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [ignore_case_convert: ["select", "where"]])
      sql_fixture("query.sql", "select * from users where age > 18;")

      Format.run(["query.sql"])
      assert File.read!("query.sql") == "select\n  *\nFROM\n  users\nwhere\n  age > 18;"

      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [ignore_case_convert: ["select"]])
      Format.run(["query.sql"])
      assert File.read!("query.sql") == "select\n  *\nFROM\n  users\nWHERE\n  age > 18;"
    end)
  end

  test "with sql path in formatter inputs", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], inputs: ["sql/**/*.sql"])
      sql_fixture("sql/path_a/query.sql")
      sql_fixture("sql/path_a/query2.sql")
      sql_fixture("sql/path_b/query.sql")
      sql_fixture("queries/query.sql")

      Format.run(["sql/**/*.sql", "queries/query.sql"])
      assert File.read!("sql/path_a/query.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("sql/path_a/query2.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("sql/path_b/query.sql") == "SELECT\n  *\nFROM\n  users"
      assert File.read!("queries/query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "with --check-formatted", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], inputs: ["*.sql"])
      sql_fixture("query.sql")

      assert_raise Mix.Error, ~r"mix format failed due to --check-formatted", fn ->
        Format.run(["--check-formatted"])
      end

      # the file has not changed
      assert File.read!("query.sql") == "select * from users"

      # format it and run with --check-formatted again
      assert Format.run([]) == :ok
      assert Format.run(["--check-formatted"]) == :ok

      assert File.read!("query.sql") == "SELECT\n  *\nFROM\n  users"
    end)
  end

  test "with different extensions", context do
    in_tmp(context.test, fn ->
      write_formatter_config(plugins: [SqlFmt.Formatter], sql_fmt: [extensions: [".sqlite"]])
      sql_fixture("query.sql")
      sql_fixture("query.sqlite")

      assert Format.run(["query.sql", "query.sqlite"]) == :ok
      assert File.read!("query.sql") == "select * from users"
      assert File.read!("query.sqlite") == "SELECT\n  *\nFROM\n  users"
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

  defp write_formatter_config(config) when is_list(config), do: write_formatter_config(inspect(config))
  defp write_formatter_config(config) when is_binary(config), do: File.write!(".formatter.exs", config)

  defp sql_fixture(path, query \\ "select * from users") do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, query)
  end
end
