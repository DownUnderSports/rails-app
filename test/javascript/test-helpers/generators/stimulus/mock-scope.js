import { Scope } from "test-helpers/mocks/stimulus/scope"

export const mockScope = (controller, element) => {
  const scope = new Scope(controller.constructor.keyName, element)

  Object.defineProperty(controller, "scope", {
    value: scope,
    configurable: false,
    writable: false
  })
}
