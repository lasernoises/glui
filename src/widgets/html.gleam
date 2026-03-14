import dom
import gleam/list
import widget.{type Widget}

pub fn element(
  tag_name: String,
  attributes: List(#(String, String)),
  events: List(#(String, dom.EventHandler)),
  content: List(Widget(in, out)),
) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, in) {
      let element = dom.create_element(tag_name)

      attributes
      |> list.each(fn(attribute) {
        let #(attribute, value) = attribute
        element |> dom.set_attribute(attribute, value)
      })

      events
      |> list.each(fn(event) {
        let #(event, handler) = event
        element |> dom.set_event_handler(event, handler)
      })

      let #(reactivity, content_state) =
        content
        |> list.map_fold(reactivity, fn(reactivity, widget) {
          let #(state, widget_element, reactivity) =
            widget |> widget.create(reactivity, in)

          element |> dom.append_child(widget_element)

          #(reactivity, #(state, widget_element))
        })

      #(content_state, element, reactivity)
    },
    update: fn(content_state, reactivity, in, _element) {
      let #(reactivity, content_state) =
        content_state
        |> list.map_fold(reactivity, fn(reactivty, state) {
          let #(state, element) = state
          let #(state, reactivity) =
            state |> widget.update(reactivty, in, element)

          #(reactivity, #(state, element))
        })

      #(content_state, reactivity)
    },
  )
}

pub fn text(text: String) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, _in) {
      let element =
        dom.create_element("span")
        |> dom.set_text_content(text)

      #(Nil, element, reactivity)
    },
    update: fn(_, reactivity, _in, _element) { #(Nil, reactivity) },
  )
}
