use rustler::Atom;
use rustler::NifStruct;
use rustler::NifTuple;
use rustler::NifUnitEnum;

use sqlformat::{Dialect, FormatOptions, Indent, QueryParams};

mod atoms {
    rustler::atoms! {
        ok,
        error
    }
}

#[derive(NifTuple)]
struct StringResultTuple {
    lhs: Atom,
    rhs: String,
}

#[derive(NifUnitEnum)]
pub enum ElixirDialect {
    Generic,
    Postgres,
    SqlServer,
}

#[derive(NifStruct)]
#[module = "SqlFmt.FormatOptions"]
pub struct ElixirFormatOptions<'a> {
    pub indent: u8,
    pub uppercase: bool,
    pub lines_between_queries: u8,
    pub ignore_case_convert: Vec<&'a str>,
    pub dialect: ElixirDialect,
    pub inline: bool,
    pub joins_as_top_level: bool,
    pub max_inline_block: usize,
    pub max_inline_arguments: Option<usize>,
    pub max_inline_top_level: Option<usize>,
}

#[rustler::nif(schedule = "DirtyCpu")]
fn format(sql_query: String, format_options: ElixirFormatOptions) -> StringResultTuple {
    let dialect = match format_options.dialect {
        ElixirDialect::Generic => Dialect::Generic,
        ElixirDialect::Postgres => Dialect::PostgreSql,
        ElixirDialect::SqlServer => Dialect::SQLServer,
    };

    let options = FormatOptions {
        indent: Indent::Spaces(format_options.indent),
        uppercase: Some(format_options.uppercase),
        lines_between_queries: format_options.lines_between_queries,
        ignore_case_convert: Some(format_options.ignore_case_convert),
        dialect: dialect,
        inline: format_options.inline,
        joins_as_top_level: format_options.joins_as_top_level,
        max_inline_block: format_options.max_inline_block,
        max_inline_arguments: format_options.max_inline_arguments,
        max_inline_top_level: format_options.max_inline_top_level,
    };

    let formatted_sql = sqlformat::format(sql_query.as_str(), &QueryParams::None, &options);

    return StringResultTuple {
        lhs: atoms::ok(),
        rhs: formatted_sql.to_string(),
    };
}

#[rustler::nif(schedule = "DirtyCpu")]
fn format(
    sql_query: String,
    query_params: Vec<String>,
    format_options: ElixirFormatOptions,
) -> StringResultTuple {
    let dialect = match format_options.dialect {
        ElixirDialect::Generic => Dialect::Generic,
        ElixirDialect::Postgres => Dialect::PostgreSql,
        ElixirDialect::SqlServer => Dialect::SQLServer,
    };

    let options = FormatOptions {
        indent: Indent::Spaces(format_options.indent),
        uppercase: Some(format_options.uppercase),
        lines_between_queries: format_options.lines_between_queries,
        ignore_case_convert: Some(format_options.ignore_case_convert),
        dialect: dialect,
        inline: format_options.inline,
        joins_as_top_level: format_options.joins_as_top_level,
        max_inline_block: format_options.max_inline_block,
        max_inline_arguments: format_options.max_inline_arguments,
        max_inline_top_level: format_options.max_inline_top_level,
    };

    let formatted_sql = sqlformat::format(
        sql_query.as_str(),
        &QueryParams::Indexed(query_params),
        &options,
    );

    return StringResultTuple {
        lhs: atoms::ok(),
        rhs: formatted_sql.to_string(),
    };
}

rustler::init!("Elixir.SqlFmt.Native");
