import gleam/dict
import gleam/list
import gleam/pair
import internal/list_util

pub type Node {
  Node(generation: Int, dirty: Bool, dependents: List(#(Int, Key)))
}

pub opaque type Reactivity {
  Reactivity(dict: dict.Dict(Int, Node), next_key: Int)
}

pub opaque type Key {
  Key(key: Int)
}

pub type Rx(a) {
  Rx(value: a, key: Int)
}

pub type Update(a) {
  Update(new_value: a, changes: List(Int))
}

pub type Get(a) {
  Get(get: fn(Reactivity) -> #(Reactivity, a))
}

pub fn new() -> Reactivity {
  Reactivity(dict.new(), 0)
}

pub fn rx(reactivity: Reactivity, value: a) -> #(Reactivity, Rx(a)) {
  let #(reactivity, key) =
    insert(reactivity, Node(generation: 0, dirty: False, dependents: []))

  #(reactivity, Rx(value, key.key))
}

pub fn insert(reactivity: Reactivity, node: Node) -> #(Reactivity, Key) {
  #(
    Reactivity(
      reactivity.dict |> dict.insert(reactivity.next_key, node),
      reactivity.next_key + 1,
    ),
    Key(reactivity.next_key),
  )
}

pub fn get(reactivity: Reactivity, key: Key) -> Result(Node, Nil) {
  reactivity.dict |> dict.get(key.key)
}

pub fn update(reactivity: Reactivity, key: Key, new_value: Node) -> Reactivity {
  Reactivity(
    ..reactivity,
    dict: reactivity.dict |> dict.insert(key.key, new_value),
  )
}

fn mark_dependents_dirty(
  reactivity: Reactivity,
  dependents: List(#(Int, Key)),
) -> #(Reactivity, List(#(Int, Key))) {
  list_util.filter_with_state(dependents, reactivity, fn(x, reactivity) {
    let #(generation, key) = x

    case get(reactivity, key) {
      Ok(node) if node.generation > generation -> #(False, reactivity)
      Ok(node) -> {
        let #(reactivity, dependents) =
          reactivity |> mark_dependents_dirty(node.dependents)

        #(
          True,
          reactivity |> update(key, Node(..node, dependents:, dirty: True)),
        )
      }
      Error(_) -> #(False, reactivity)
    }
  })
  |> pair.swap()
}

fn mark_dirty(reactivity: Reactivity, key: Key) -> Reactivity {
  case get(reactivity, key) {
    Ok(node) -> {
      let #(reactivity, dependents) =
        mark_dependents_dirty(reactivity, node.dependents)

      let reactivity = update(reactivity, key, Node(..node, dependents:))

      reactivity
    }
    Error(_) -> reactivity
  }
}

pub fn rx_update(
  value: Rx(a),
  replace: fn(a) -> a,
  f: fn(Rx(a)) -> Update(b),
) -> Update(b) {
  let update = f(Rx(..value, value: replace(value.value)))

  Update(..update, changes: [value.key, ..update.changes])
}

pub fn rx_update_apply(update: Update(a), reactivity: Reactivity) -> Reactivity {
  use reactivity, key <- list.fold(update.changes, reactivity)

  let reactivity = mark_dirty(reactivity, Key(key))

  reactivity
}

pub fn finish(value: a) -> Update(a) {
  Update(value, [])
}

pub fn rx_get(value: Rx(a), get: fn(a) -> b) -> Get(b) {
  Get(fn(reactivity) {
    // TODO: track
    #(reactivity, get(value.value))
  })
}
