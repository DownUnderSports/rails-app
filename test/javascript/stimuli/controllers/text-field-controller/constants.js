import { TextFieldController } from "stimuli/controllers/text-field-controller"
import { Scope } from "test-helpers/mocks/stimulus/scope"
import { sleepAsync } from "test-helpers/sleep-async"

TextFieldController.bless()

export const getElements = () => {
  const wrapper = document.getElementById("test-text-field"),
        input = document.getElementById("test-email"),
        label = wrapper.querySelector("label"),
        icon = wrapper.querySelector("i")

  return { wrapper, input, label, icon }
}

export const template = `
<div id="test-text-field" class="mdc-text-field" data-controller="text-field">
  <input id="test-email" data-target="text-field.input" class="mdc-text-field__input" />
  <i class="material-icons mdc-text-field__icon" data-target="text-field.icon">
    email
  </i>
  <label for="test-email" data-target="text-field.label">Email</label>
</div>
`

export const registerController = async () => {
  document.body.innerHTML = template

  TextFieldController.registerController()
  await sleepAsync()
}

export const mockScope = async (controller, element) => {
  const scope = new Scope(TextFieldController.keyName, element)

  if(!controller.testName) controller.testName = window.testName || expect.getState().currentTestName

  Object.defineProperty(controller, "scope", {
    value: scope,
    configurable: true,
    writable: true
  })
}

export const createTemplateController = () => {
  document.body.innerHTML = template
  const { wrapper } = getElements()
  const controller = new TextFieldController()
  controller.testName = window.testName || expect.getState().currentTestName
  mockScope(controller, wrapper)
  return controller
}
