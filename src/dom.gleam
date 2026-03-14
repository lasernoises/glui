pub type Element

pub type EventHandler

pub type EventContent {
  Click
}

pub type Event {
  Event(path: List(Element), content: EventContent)
}

@external(javascript, "./dom_ffi.mjs", "createElement")
pub fn create_element(tag: String) -> Element

@external(javascript, "./dom_ffi.mjs", "body")
pub fn body() -> Element

@external(javascript, "./dom_ffi.mjs", "appendChild")
pub fn append_child(element: Element, child: Element) -> Element

@external(javascript, "./dom_ffi.mjs", "setAttribute")
pub fn set_attribute(
  element: Element,
  attribute: String,
  value: String,
) -> Element

@external(javascript, "./dom_ffi.mjs", "setTextContent")
pub fn set_text_content(element: Element, text: String) -> Element

@external(javascript, "./dom_ffi.mjs", "setEventHandler")
pub fn set_event_handler(
  element: Element,
  event: String,
  handler: EventHandler,
) -> Element

@external(javascript, "./dom_ffi.mjs", "contextualizeEventHandler")
pub fn contextualize_event_handler(
  handler: EventHandler,
  element: Element,
) -> EventHandler

@external(javascript, "./dom_ffi.mjs", "run")
pub fn run(
  init: fn(EventHandler) -> a,
  update: fn(a, EventHandler, Event) -> a,
) -> Nil
