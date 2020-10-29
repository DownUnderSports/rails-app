import { DataMap } from "./data-map"
import { Schema } from "./schema"
import { TargetSet } from "./target-set"
import { attributeContainsToken } from "test-helpers/attribute-contains-token";

export class Scope {
  constructor(identifier, element) {
    this.schema = Schema
    this.identifier = identifier
    this.element = element
    this.targets = new TargetSet(this)
    this.data = new DataMap(this)
  }

  findElement = (selector) =>
    this.element.matches(selector)
      ? this.element
      : this.queryElements(selector).find(this.containsElement)

  findAllElements = (selector) =>
    [
      ...this.element.matches(selector) ? [this.element] : [],
      ...this.queryElements(selector).filter(this.containsElement)
    ]

  containsElement = (element) =>
    element.closest(this.controllerSelector) === this.element

  queryElements = (selector) =>
    Array.from(this.element.querySelectorAll(selector))

  get controllerSelector() {
    return attributeContainsToken(this.schema.controllerAttribute, this.identifier)
  }
}
