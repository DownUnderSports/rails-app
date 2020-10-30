import { TopBarController } from "stimuli/controllers/top-bar-controller"
import { controllerRegistration } from "test-helpers/generators/stimulus/controller-registration"

export const getElements = () => {
  const wrapper = document.getElementById("test-top-bar"),
        title = wrapper.querySelector(".mdc-top-app-bar__title"),
        icon = wrapper.querySelector("#drawer-toggle-button")

  return { wrapper, title, icon }
}

export const template = `
<section>
  <header
    id="test-top-bar"
    class="mdc-top-app-bar mdc-top-app-bar--fixed"
    data-controller="top-bar"
  >
    <div class="mdc-top-app-bar__row">
      <section class="mdc-top-app-bar__section mdc-top-app-bar__section--align-start h-100 flex-grow">
      </section>
      <section class="mdc-top-app-bar__section mdc-top-app-bar__section--align-end">
        <span class="mdc-top-app-bar__title" data-target="top-bar.title">
          Title
        </span>
        <button
          id="drawer-toggle-button"
          class="material-icons mdc-top-app-bar__navigation-icon mdc-icon-button edge-even"
          data-target="top-bar.nav-button"
          data-action="app-drawer#toggle"
        >
          menu
        </button>
      </section>
    </div>
  </header>
</section>
`

export const { registerController, unregisterController } = controllerRegistration(TopBarController, template)
