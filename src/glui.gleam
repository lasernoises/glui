import dom
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import reactivity
import widget
import widgets/component.{type ComponentInput, ComponentOutput}
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

      let #(state, reactivity) =
        state |> widget.update(reactivity, handler, element, Nil)

      #(state, reactivity, element)
    },
  )

  Nil
}

pub fn my_widget() -> widget.Widget(in, String) {
  component.component(
    fn(reactivity) { reactivity.rx(reactivity, 0) },
    html.element(
      "div",
      [
        #("style", "color: blue"),
      ],
      fn(in, event) { option.None },
      [
        html.text("the one"),
        html.rx_text(fn(a: ComponentInput(_, _)) {
          reactivity.rx_get(a.state, int.to_string)
        }),
        html.rx_text(fn(a: ComponentInput(_, _)) {
          reactivity.rx_get(a.state, fn(_) { "abc" })
        }),
        html.element(
          "button",
          [],
          fn(in, event) {
            Some(ComponentOutput(
              fn(a) {
                use a <- reactivity.rx_update(a, fn(x) { x + 1 })
                reactivity.finish(a)
              },
              "Click",
            ))
          },
          [
            html.text("click me"),
          ],
        ),
      ],
    ),
  )
}
