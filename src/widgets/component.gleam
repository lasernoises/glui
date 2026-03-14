import reactivity
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
  initial: fn() -> a,
  inner: Widget(ComponentInput(a, in), ComponentOutput(a, out)),
) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, in) {
      let state = initial()

      let #(inner, element, reactivity) =
        inner |> widget.create(reactivity, ComponentInput(state, in))

      #(ComponentState(state, inner), element, reactivity)
    },
    update: fn(state, reactivity, in, element) {
      let #(inner, reactivity) =
        state.inner
        |> widget.update(reactivity, ComponentInput(state.state, in), element)

      #(ComponentState(..state, inner:), reactivity)
    },
  )
}
