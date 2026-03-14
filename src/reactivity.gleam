import gleam/dict
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
  Rx(value: a)
}

pub opaque type Update(a) {
  Update(update: fn(Reactivity, a) -> #(Reactivity, a))
}

pub opaque type Get(a) {
  Get(get: fn(Reactivity) -> #(Reactivity, a))
}

pub fn new() -> Reactivity {
  Reactivity(dict.new(), 0)
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

pub fn mark_dirty(
  reactivity: Reactivity,
  dependents: List(#(Int, Key)),
) -> #(Reactivity, List(#(Int, Key))) {
  list_util.filter_with_state(dependents, reactivity, fn(x, reactivity) {
    let #(generation, key) = x

    case get(reactivity, key) {
      Ok(node) if node.generation > generation -> #(False, reactivity)
      Ok(node) -> {
        let #(reactivity, dependents) =
          reactivity |> mark_dirty(node.dependents)

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
