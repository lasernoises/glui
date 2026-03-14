import gleam/list

pub fn filter_with_state(
  list: List(a),
  state: b,
  predicate: fn(a, b) -> #(Bool, b),
) -> #(List(a), b) {
  filter_with_state_loop(list, state, predicate, [])
}

fn filter_with_state_loop(
  list: List(a),
  state: b,
  predicate: fn(a, b) -> #(Bool, b),
  acc: List(a),
) -> #(List(a), b) {
  case list {
    [] -> #(list.reverse(acc), state)
    [first, ..rest] -> {
      let #(keep, state) = predicate(first, state)

      let acc = case keep {
        True -> [first, ..acc]
        False -> acc
      }

      filter_with_state_loop(rest, state, predicate, acc)
    }
  }
}
