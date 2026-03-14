import dom
import gleam/list
import gleam/option.{type Option, None}
import widget.{type Widget}

pub fn element(
  tag_name: String,
  attributes: List(#(String, String)),
  on_click: fn(in, dom.EventContent) -> Option(out),
  content: List(Widget(in, out)),
) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, event_handler, in) {
      let element = dom.create_element(tag_name)

      attributes
      |> list.each(fn(attribute) {
        let #(attribute, value) = attribute
        element |> dom.set_attribute(attribute, value)
      })

      let event_handler =
        dom.contextualize_event_handler(event_handler, element)

      element
      |> dom.set_event_handler("click", event_handler)

      let #(reactivity, content_state) =
        content
        |> list.map_fold(reactivity, fn(reactivity, widget) {
          let #(state, widget_element, reactivity) =
            widget
            |> widget.create(reactivity, event_handler, in)

          element |> dom.append_child(widget_element)

          #(reactivity, #(state, widget_element))
        })

      #(content_state, element, reactivity)
    },
    update: fn(content_state, reactivity, event_handler, _element, in) {
      let #(reactivity, content_state) =
        content_state
        |> list.map_fold(reactivity, fn(reactivty, state) {
          let #(state, element) = state
          let #(state, reactivity) =
            state |> widget.update(reactivty, event_handler, element, in)

          #(reactivity, #(state, element))
        })

      #(content_state, reactivity)
    },
    handle_event: fn(
      content_state,
      reactivity,
      event_handler,
      element,
      in,
      event,
    ) {
      case event.path {
        [] -> #(content_state, reactivity, on_click(in, event.content))
        [first, ..rest] -> {
          let event_handler =
            dom.contextualize_event_handler(event_handler, element)

          let #(#(reactivity, out), content_state) =
            content_state
            // TODO: something more efficient
            |> list.map_fold(#(reactivity, None), fn(acc, x) {
              case dom.element_eq(x.1, first) {
                True -> {
                  let #(reactivity, _) = acc
                  let #(state, widget_element) = x
                  let #(state, reactivity, out) =
                    state
                    |> widget.handle_event(
                      reactivity,
                      event_handler,
                      widget_element,
                      in,
                      dom.Event(rest, event.content),
                    )

                  #(#(reactivity, out), #(state, widget_element))
                }
                False -> #(acc, x)
              }
            })

          #(content_state, reactivity, out)
        }
      }
    },
  )
}

pub fn text(text: String) -> Widget(in, out) {
  widget.new(
    create: fn(reactivity, _, _in) {
      let element =
        dom.create_element("span")
        |> dom.set_text_content(text)

      #(Nil, element, reactivity)
    },
    update: fn(_, reactivity, _, _, _in) { #(Nil, reactivity) },
    handle_event: fn(_, reactivity, _, _, _in, _event) {
      #(Nil, reactivity, None)
    },
  )
}
