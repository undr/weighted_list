pub mod table;

use crate::table::Table;

use rustler::{Encoder, NifResult, Term, Env, ResourceArc, Resource, Atom};
use rustler::Error as RustlerError;

// use std::collections::HashMap;

struct TableResource(Table);

#[rustler::resource_impl]
impl Resource for TableResource {}

#[rustler::nif]
fn setup<'a>(env: Env<'a>, values: Vec<u32>, weights: Vec<u64>) -> NifResult<Term<'a>> {
    match Table::build(values, weights) {
        Some(table) => Ok(ResourceArc::new(TableResource(table)).encode(env)),
        None => Err(RustlerError::BadArg),
    }
}

#[rustler::nif]
fn size(resource: ResourceArc<TableResource>) -> u32 {
    return resource.0.size().try_into().unwrap();
}

#[rustler::nif]
fn get(resource: ResourceArc<TableResource>, idx: u32, rng: f32) -> Result<u32, Atom> {
    match resource.0.get(idx, rng) {
        Some(value) => Ok(value),
        None => Err(atoms::index()),
    }
}

#[rustler::nif]
fn index(resource: ResourceArc<TableResource>, idx: u32, rng: f32) -> Result<u32, Atom> {
    match resource.0.get_idx(idx, rng) {
        Some(value) => Ok(value),
        None => Err(atoms::index()),
    }
}

#[rustler::nif]
fn values(resource: ResourceArc<TableResource>) -> Vec<u32> {
    resource.0.get_values()
}

#[rustler::nif]
fn aliases(resource: ResourceArc<TableResource>) -> Vec<usize> {
    resource.0.get_aliases()
}

#[rustler::nif]
fn probs(resource: ResourceArc<TableResource>) -> Vec<f32> {
    resource.0.get_probs()
}

mod atoms {
    rustler::atoms! {
        ok,
        error,
        index,
    }
}

rustler::init!("Elixir.WeightedList.Native");