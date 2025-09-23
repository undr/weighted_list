pub mod table;

use crate::table::Table;

use rustler::{Encoder, NifResult, Term, Env, ResourceArc, Resource, Atom};
use rustler::Error as RustlerError;
use rustler::types::list::ListIterator;

// use std::collections::HashMap;

#[derive(Debug, Clone)]
pub enum PrimitiveValue {
    UInt32(u32),
    Float32(f32),
    Utf8(Option<String>),
}

impl Encoder for PrimitiveValue {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            PrimitiveValue::UInt32(v) => v.encode(env),
            PrimitiveValue::Float32(v) => v.encode(env),
            PrimitiveValue::Utf8(v) => v.encode(env),
        }
    }
}

struct TableResource(Table<PrimitiveValue>);

#[rustler::resource_impl]
impl Resource for TableResource {}

#[rustler::nif]
fn setup<'a>(env: Env<'a>, values: Term, weights: Vec<u64>) -> NifResult<Term<'a>> {
    let iter: ListIterator = values.decode()?;
    let vec: Vec<PrimitiveValue> = iter
        .map(|x| {
            if x.is_float() {
                x.decode::<f32>().and_then(|i| NifResult::Ok(PrimitiveValue::Float32(i)))
            } else if x.is_integer() {
                x.decode::<u32>().and_then(|i| NifResult::Ok(PrimitiveValue::UInt32(i)))
            } else if x.is_binary() {
                x.decode::<String>().and_then(|i| NifResult::Ok(PrimitiveValue::Utf8(Some(i))))
            } else {
                NifResult::Ok(PrimitiveValue::Utf8(None))
            }
        })
        .collect::<NifResult<Vec<PrimitiveValue>>>()?;

    match Table::build(vec, weights) {
        Some(table) => Ok(ResourceArc::new(TableResource(table)).encode(env)),
        None => Err(RustlerError::BadArg),
    }
}

#[rustler::nif]
fn size(resource: ResourceArc<TableResource>) -> u32 {
    return resource.0.size().try_into().unwrap();
}

#[rustler::nif]
fn get<'a>(env: Env<'a>, resource: ResourceArc<TableResource>, idx: u32, rng: f32) -> Result<Term<'a>, Atom> {
    match resource.0.get(idx, rng) {
        Some(value) => Ok(value.encode(env)),
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
fn values(env: Env, resource: ResourceArc<TableResource>) -> Vec<Term> {
    resource.0.get_values().into_iter().map(|x| x.encode(env)).collect()
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