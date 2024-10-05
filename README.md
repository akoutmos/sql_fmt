<p align="center">
  <img align="center" width="25%" src="guides/images/logo.png" alt="sql_fmt Logo">
  <img align="center" width="35%" src="guides/images/logo_name.png" alt="sql_fmt title">
</p>

<p align="center">
  Format and pretty print raw SQL queries
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
- [Supporting SqlFmt](#supporting-ectodbg)
- [Setting Up SqlFmt](#setting-up-ectodbg)
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

## Example Output

After setting up SqlFmt in your application you can expect the following output from your Ecto queries when using the
SqlFmt helpers:

<img align="center" src="guides/images/example_output.png" alt="SqlFmt example output">

## Supporting SqlFmt

If you rely on this library help you debug your Ecto queries, it would much appreciated if you can give back
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

## Setting Up SqlFmt

After adding `{:sql_fmt, "~> 0.1.0"}` in your `mix.exs` file and running `mix deps.get`, open your `repo.ex` file and
add the following contents:

## Attribution

- The logo for the project is an edited version of an SVG image from the [unDraw project](https://undraw.co/).
- The SqlFmt library leans on the Rust library [sqlformat-rs](https://github.com/shssoichiro/sqlformat-rs) for SQL
  statement formatting.
