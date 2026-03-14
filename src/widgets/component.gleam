import gleam/option
import reactivity.{type Reactivity}
import widget.{type Widget, type WidgetState}

pub type ComponentInput(a, in) {
  ComponentInput(state: a, input: in)
}

pub type ComponentOutput(a, out) {
  ComponentOutput(state: fn(a) -> reactivity.Update(a), output: out)
}

type ComponentState(a, in, out) {
  ComponentState(
    state: a,
    inner: WidgetState(ComponentInput(a, in), ComponentOutput(a, out)),
  )
}

pub fn component(
  initial: fn(Reactivity) -> #(Reactivity, a),
  inner: Widget(ComponentInput(a, in), ComponentOutput(a, out)),
) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, event_handler, in) {
      let #(reactivity, state) = initial(reactivity)

      let #(inner, element, reactivity) =
        inner
        |> widget.create(reactivity, event_handler, ComponentInput(state, in))

      #(ComponentState(state, inner), element, reactivity)
    },
    update: fn(state, reactivity, event_handler, element, in) {
      let #(inner, reactivity) =
        state.inner
        |> widget.update(
          reactivity,
          event_handler,
          element,
          ComponentInput(state.state, in),
        )

      #(ComponentState(..state, inner:), reactivity)
    },
    handle_event: fn(state, reactivity, event_handler, element, in, event) {
      let #(inner, reactivity, out) =
        state.inner
        |> widget.handle_event(
          reactivity,
          event_handler,
          element,
          ComponentInput(state.state, in),
          event,
        )

      let #(state, reactivity) =
        out
        |> option.map(fn(out) {
          let update = out.state(state.state)

          reactivity.rx_update_apply(update, reactivity)

          #(update.new_value, reactivity)
        })
        |> option.unwrap(#(state.state, reactivity))

      #(
        ComponentState(state, inner),
        reactivity,
        out |> option.map(fn(out) { out.output }),
      )
    },
  )
}
