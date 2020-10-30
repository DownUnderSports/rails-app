import { ListController } from "stimuli/controllers/list-controller"
import { controllerRegistration } from "test-helpers/generators/stimulus/controller-registration"

ListController.bless()

// export const falsy = [ false, 0, "", null, undefined ]

export const getElements = () => {
  const wrapper = document.getElementById("test-list"),
        items = wrapper.querySelectorAll(".mdc-list-item")

  return { wrapper, items }
}

export const template = `
<ul id="test-list" class="mdc-list mdc-list--two-line" data-controller="list" data-target="list.list">
  <li class="mdc-list-item" tabindex="0" data-target="list.item">
    <span class="mdc-list-item__text">
      <span class="mdc-list-item__primary-text">Item One</span>
      <span class="mdc-list-item__secondary-text">Line Two</span>
    </span>
  </li>
  <li class="mdc-list-item" data-target="list.item">
    <span class="mdc-list-item__text">
      <span class="mdc-list-item__primary-text">Item Two</span>
      <span class="mdc-list-item__secondary-text">Line Two</span>
    </span>
  </li>
  <li class="mdc-list-item" data-target="list.item">
    <span class="mdc-list-item__text">Item Three</span>
  </li>
</ul>
`

export const { registerController, unregisterController } = controllerRegistration(ListController, template)
