use lazy_static::lazy_static;
use regex::Regex;
use rustler::Atom;
use rustler::NifStruct;
use rustler::NifTuple;

lazy_static! {
    static ref OPERATOR_REGEX: Regex =
        Regex::new(r"([+\-*/<=>\~!@#%^&|`?])\s([+\-*/<=>\~!@#%^&|`?])").unwrap();
}

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
    let post_process_query = post_process_query(formatted_sql);

    return StringResultTuple {
        lhs: atoms::ok(),
        rhs: post_process_query.to_string(),
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
    let post_process_query = post_process_query(formatted_sql);

    return StringResultTuple {
        lhs: atoms::ok(),
        rhs: post_process_query.to_string(),
    };
}

// ---- Private helper functions ----

// This is a work around the following bug in the Rust formatting
// library https://github.com/shssoichiro/sqlformat-rs/issues/52
//
// 63 Regex replacement passes has been chosen as it is the default max
// operator name as per the Postgres docs https://www.postgresql.org/docs/current/sql-createoperator.html.
// The function will break early if no more replacements need to occur though.

fn post_process_query(formatted_query: String) -> String {
    let mut current_string = formatted_query;

    for _ in 0..63 {
        let new_string = OPERATOR_REGEX
            .replace_all(&current_string, "$1$2")
            .to_string();

        if current_string == new_string {
            return new_string;
        }

        current_string = new_string;
    }

    current_string
}

rustler::init!("Elixir.SqlFmt.Native");
