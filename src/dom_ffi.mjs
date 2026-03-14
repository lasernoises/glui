import { List$Empty, List$NonEmpty } from "./gleam.mjs";
import { reverse } from "../gleam_stdlib/gleam/list.mjs";
import { EventContent$Click, Event$Event } from "./dom.mjs";

export function createElement(tag) {
  return document.createElement(tag);
}

export function body() {
  return document.body;
}

export function appendChild(element, child) {
  element.appendChild(child);
  return element;
}

export function setAttribute(element, attribute, value) {
  element.setAttribute(attribute, value)
  return element;
}

export function setTextContent(element, text) {
  element.textContent = text;
  return element;
}

export function setEventHandler(element, event, handler) {
  const path = reverse(handler.path);
  element.addEventListener(event, (_) => {
    handler.update(Event$Event(path, EventContent$Click()));
  });
}

export function contextualizeEventHandler(handler, element) {
  return {
    path: List$NonEmpty(element, handler.path),
  };
}

// this is where the bodies are buried
export function run(init, update) {
  const event_handler = {
      path: List$Empty(),
      update: (event) => {
        state = update(state, event_handler, event);
      },
  };

  let state = init(event_handler);
}
