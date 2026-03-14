import dom
import reactivity.{type Reactivity}

pub opaque type Widget(in, out) {
  Widget(
    create: fn(Reactivity, in) ->
      #(WidgetState(in, out), dom.Element, Reactivity),
  )
}

pub opaque type WidgetState(in, out) {
  WidgetState(
    update: fn(Reactivity, in, dom.Element) ->
      #(WidgetState(in, out), Reactivity),
  )
}

pub fn create(
  widget: Widget(in, out),
  reactivity: Reactivity,
  in: in,
) -> #(WidgetState(in, out), dom.Element, Reactivity) {
  widget.create(reactivity, in)
}

pub fn update(
  state: WidgetState(in, out),
  reactivity: Reactivity,
  in: in,
  element: dom.Element,
) -> #(WidgetState(in, out), Reactivity) {
  state.update(reactivity, in, element)
}

pub fn new(
  create create: fn(Reactivity, in) -> #(state, dom.Element, Reactivity),
  update update: fn(state, Reactivity, in, dom.Element) -> #(state, Reactivity),
) -> Widget(in, out) {
  Widget(fn(reactivity, in) {
    let #(state, element, reactivity) = create(reactivity, in)
    #(widget_state(state, update), element, reactivity)
  })
}

fn widget_state(
  state: state,
  update: fn(state, Reactivity, in, dom.Element) -> #(state, Reactivity),
) -> WidgetState(in, out) {
  WidgetState(fn(reactivity, in, element) {
    let #(state, reactivity) = update(state, reactivity, in, element)
    #(widget_state(state, update), reactivity)
  })
}
