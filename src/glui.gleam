import dom
import gleam/io
import reactivity
import widget
import widgets/html

pub fn main() -> Nil {
  dom.run(
    fn(h) {
      let widget = my_widget(h)

      let #(state, element, reactivity) =
        widget.create(widget, reactivity.new(), Nil)

      dom.body()
      |> dom.append_child(element)

      Nil
    },
    fn(state, handler, event) { io.print("event") },
  )

  Nil
}

pub fn my_widget(h: dom.EventHandler) -> widget.Widget(in, out) {
  html.element(
    "div",
    [
      #("style", "color: blue"),
    ],
    [
      #("click", h),
    ],
    [html.text("the one")],
  )
}
