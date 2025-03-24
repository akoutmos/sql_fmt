use rustler::Atom;
use rustler::NifStruct;
use rustler::NifTuple;

use sqruff_lib::api::simple;

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
fn format(sql_query: &str, format_options: ElixirFormatOptions) -> StringResultTuple {
    let formatted_sql = simple::fix(sql_query);

    return StringResultTuple {
        lhs: atoms::ok(),
        rhs: formatted_sql,
    };
}

rustler::init!("Elixir.SqlFmt.Native");
