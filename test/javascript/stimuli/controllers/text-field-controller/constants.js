import { TextFieldController } from "stimuli/controllers/text-field-controller"
import { controllerRegistration } from "test-helpers/generators/stimulus/controller-registration"
import { TemplateController } from "test-helpers/generators/stimulus/template-controller"

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

export const createTemplateController = TemplateController(TextFieldController, template, "#test-text-field")

export const { registerController, unregisterController } = controllerRegistration(TextFieldController, template)
