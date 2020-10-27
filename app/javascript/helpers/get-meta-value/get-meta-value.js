import { findElement } from "helpers"

export function getMetaValue(name) {
  const element = findElement(document.head, `meta[name="${name}"]`)
  if (element) {
    return element.getAttribute("content")
  }
}
