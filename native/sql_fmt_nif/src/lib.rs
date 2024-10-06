use rustler::Atom;
use rustler::NifStruct;
use rustler::NifTuple;

use sqlformat::{FormatOptions, Indent, QueryParams};

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

#[derive(NifStruct)]
#[module = "SqlFmt.FormatOptions"]
pub struct ElixirFormatOptions<'a> {
    pub indent: u8,
    pub uppercase: bool,
    pub lines_between_queries: u8,
    pub ignore_case_convert: Vec<&'a str>,
}

#[rustler::nif(schedule = "DirtyCpu")]
fn format(sql_query: String, format_options: ElixirFormatOptions) -> StringResultTuple {
    let options = FormatOptions {
        indent: Indent::Spaces(format_options.indent),
        uppercase: Some(format_options.uppercase),
        lines_between_queries: format_options.lines_between_queries,
        ignore_case_convert: Some(format_options.ignore_case_convert),
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
    let options = FormatOptions {
        indent: Indent::Spaces(format_options.indent),
        uppercase: Some(format_options.uppercase),
        lines_between_queries: format_options.lines_between_queries,
        ignore_case_convert: Some(format_options.ignore_case_convert),
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
