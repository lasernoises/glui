import dom
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import reactivity
import widget
import widgets/html

pub fn main() -> Nil {
  dom.run(
    fn(h) {
      let widget = my_widget()

      let #(state, element, reactivity) =
        widget.create(widget, reactivity.new(), h, Nil)

      dom.body()
      |> dom.append_child(element)

      #(state, reactivity, element)
    },
    fn(x, handler, event) {
      let #(state, reactivity, element) = x

      assert list.first(event.path)
        |> result.map(fn(e) { dom.element_eq(e, element) })
        |> result.unwrap(False)

      let event =
        dom.Event(list.rest(event.path) |> result.unwrap([]), event.content)

      let #(state, reactivity, out) =
        state |> widget.handle_event(reactivity, handler, element, Nil, event)

      case out {
        Some(text) -> io.println(text)
        option.None -> Nil
      }

      #(state, reactivity, element)
    },
  )

  Nil
}

pub fn my_widget() -> widget.Widget(in, String) {
  html.element(
    "div",
    [
      #("style", "color: blue"),
    ],
    fn(in, event) { Some("hello") },
    [
      html.text("the one"),
      html.element("button", [], fn(in, event) { Some("cliiick") }, [
        html.text("click me"),
      ]),
    ],
  )
}
