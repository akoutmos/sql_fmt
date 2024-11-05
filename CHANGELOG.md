# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2024-11-04

### Added

- SqlFmt now makes use of `datafusion-sqlparser-rs` in order to parse and validate SQL queries prior to formatting them.

### Fixed

- Updated to a newer version of `sqlformat-rs` to avoid splitting Postgres operators.

## [0.2.0] - 2024-10-08

### Added

- The `~SQL` sigil to format SQL strings in Elixir code [#3](https://github.com/akoutmos/sql_fmt/pull/3).
- A Mix Formatter plugin so that SQL files and `~SQL` sigil statements are formatted via Mix [#3](https://github.com/akoutmos/sql_fmt/pull/3).

## [0.1.0] - 2024-10-06

### Added

- Initial release for SqlFmt.
