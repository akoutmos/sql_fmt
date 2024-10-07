<p align="center">
  <img align="center" width="25%" src="guides/images/logo.png" alt="sql_fmt Logo">
  <img align="center" width="35%" src="guides/images/logo_name.png" alt="sql_fmt title">
</p>

<p align="center">
  Format and pretty print SQL queries
</p>

<p align="center">
  <a href="https://hex.pm/packages/sql_fmt">
    <img alt="Hex.pm" src="https://img.shields.io/hexpm/v/sql_fmt?style=for-the-badge">
  </a>

  <a href="https://github.com/akoutmos/sql_fmt/actions">
    <img alt="GitHub Workflow Status (master)"
    src="https://img.shields.io/github/actions/workflow/status/akoutmos/sql_fmt/main.yml?label=Build%20Status&style=for-the-badge&branch=master">
  </a>

  <a href="https://coveralls.io/github/akoutmos/sql_fmt?branch=master">
    <img alt="Coveralls master branch" src="https://img.shields.io/coveralls/github/akoutmos/sql_fmt/master?style=for-the-badge">
  </a>

  <a href="https://github.com/sponsors/akoutmos">
    <img alt="Support the project" src="https://img.shields.io/badge/Support%20the%20project-%E2%9D%A4-lightblue?style=for-the-badge">
  </a>
</p>

<br>

# Contents

- [Installation](#installation)
- [Example Output](#example-output)
- [Supporting SqlFmt](#supporting-sqlfmt)
- [Attribution](#attribution)

## Installation

[Available in Hex](https://hex.pm/packages/sql_fmt), the package can be installed by adding `sql_fmt` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sql_fmt, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/sql_fmt](https://hexdocs.pm/sql_fmt).

## Usage

After setting up `SqlFmt` in your application you can use the `SqlFmt` functions in order to format queries. Here are a
couple examples of queries with having parameters inline and with passing in the parameters separately:

```elixir
iex(1)> {:ok, formatted_sql} = SqlFmt.format_query("select * from businesses where id in ('c6f5c5f1-a1fc-4c9a-91f7-6aa40f1e233d', 'f339d4ce-96b6-4440-a541-28a0fb611139');")
{:ok, "SELECT\n  *\nFROM\n  businesses\nWHERE\n  id IN (\n    'c6f5c5f1-a1fc-4c9a-91f7-6aa40f1e233d',\n    'f339d4ce-96b6-4440-a541-28a0fb611139'\n  );"}

iex(2)> IO.puts(formatted_sql)
SELECT
  *
FROM
  businesses
WHERE
  id IN (
    'c6f5c5f1-a1fc-4c9a-91f7-6aa40f1e233d',
    'f339d4ce-96b6-4440-a541-28a0fb611139'
  );
:ok
```

```elixir
iex(1)> {:ok, formatted_sql} = SqlFmt.format_query_with_params("select * from help where help.\"col\" in $1;", ["'asdf'"])
{:ok, "SELECT\n  *\nFROM\n  help\nWHERE\n  help.\"col\" IN 'asdf';"}

iex(2)> IO.puts(formatted_sql)
SELECT
  *
FROM
  help
WHERE
  help."col" IN 'asdf';
:ok
```

Be sure to checkout the HexDocs as you can also provide formatting options to the functions to tailor the output to your
liking.

## Mix task

A `mix sql_fmt.format` task is provided that can be used in order to
format a set of files, similarly to `mix format`.

```bash
# you can pass one or more paths or patterns to be formatted
$ mix sql_fmt.format query.sql "sql/**/*.sql.ex"

# you can pass the --check-formatted option to make it raise if any
# file is not formatted
$ mix sql_fmt.format --check-formatted "sql/**/*.sql.ex"
```

For more details on the supported options check the help:

```bash
$ mix help sql_fmt.format
```


## Supporting SqlFmt

If you rely on this library help you debug your Ecto/SQL queries, it would much appreciated if you can give back
to the project in order to help ensure its continued development.

Checkout my [GitHub Sponsorship page](https://github.com/sponsors/akoutmos) if you want to help out!

### Gold Sponsors

<a href="https://github.com/sponsors/akoutmos/sponsorships?sponsor=akoutmos&tier_id=58083">
  <img align="center" height="175" src="guides/images/your_logo_here.png" alt="Support the project">
</a>

### Silver Sponsors

<a href="https://github.com/sponsors/akoutmos/sponsorships?sponsor=akoutmos&tier_id=58082">
  <img align="center" height="150" src="guides/images/your_logo_here.png" alt="Support the project">
</a>

### Bronze Sponsors

<a href="https://github.com/sponsors/akoutmos/sponsorships?sponsor=akoutmos&tier_id=17615">
  <img align="center" height="125" src="guides/images/your_logo_here.png" alt="Support the project">
</a>

## Attribution

- The logo for the project is an edited version of an SVG image from the [unDraw project](https://undraw.co/).
- The SqlFmt library leans on the Rust library [sqlformat-rs](https://github.com/shssoichiro/sqlformat-rs) for SQL
  statement formatting.
