import dom.{type Element, type Event, type EventHandler}
import gleam/option.{type Option}
import reactivity.{type Reactivity}

pub opaque type Widget(in, out) {
  Widget(
    create: fn(Reactivity, EventHandler, in) ->
      #(WidgetState(in, out), Element, Reactivity),
  )
}

pub opaque type WidgetState(in, out) {
  WidgetState(
    update: fn(Reactivity, EventHandler, Element, in) ->
      #(WidgetState(in, out), Reactivity),
    handle_event: fn(Reactivity, EventHandler, Element, in, Event) ->
      #(WidgetState(in, out), Reactivity, Option(out)),
  )
}

pub fn create(
  widget: Widget(in, out),
  reactivity: Reactivity,
  event_handler: EventHandler,
  in: in,
) -> #(WidgetState(in, out), Element, Reactivity) {
  widget.create(reactivity, event_handler, in)
}

pub fn update(
  state: WidgetState(in, out),
  reactivity: Reactivity,
  event_handler: EventHandler,
  element: Element,
  in: in,
) -> #(WidgetState(in, out), Reactivity) {
  state.update(reactivity, event_handler, element, in)
}

pub fn handle_event(
  state: WidgetState(in, out),
  reactivity: Reactivity,
  event_handler: EventHandler,
  element: Element,
  in: in,
  event: Event,
) -> #(WidgetState(in, out), Reactivity, Option(out)) {
  state.handle_event(reactivity, event_handler, element, in, event)
}

pub fn new(
  create create: fn(Reactivity, EventHandler, in) ->
    #(state, Element, Reactivity),
  update update: fn(state, Reactivity, EventHandler, Element, in) ->
    #(state, Reactivity),
  handle_event handle_event: fn(
    state,
    Reactivity,
    EventHandler,
    Element,
    in,
    Event,
  ) ->
    #(state, Reactivity, Option(out)),
) -> Widget(in, out) {
  Widget(fn(reactivity, event_handler, in) {
    let #(state, element, reactivity) = create(reactivity, event_handler, in)
    #(widget_state(state, update, handle_event), element, reactivity)
  })
}

fn widget_state(
  state: state,
  update: fn(state, Reactivity, EventHandler, Element, in) ->
    #(state, Reactivity),
  handle_event: fn(state, Reactivity, EventHandler, Element, in, Event) ->
    #(state, Reactivity, Option(out)),
) -> WidgetState(in, out) {
  WidgetState(
    fn(reactivity, event_handler, element, in) {
      let #(state, reactivity) =
        update(state, reactivity, event_handler, element, in)
      #(widget_state(state, update, handle_event), reactivity)
    },
    fn(reactivity, event_handler, element, in, event) {
      let #(state, reactivity, out) =
        handle_event(state, reactivity, event_handler, element, in, event)

      #(widget_state(state, update, handle_event), reactivity, out)
    },
  )
}
