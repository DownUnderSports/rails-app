import { TimeSyncController } from "stimuli/controllers/time-sync-controller"
import { controllerRegistration } from "test-helpers/generators/stimulus/controller-registration"
import { TemplateController } from "test-helpers/generators/stimulus/template-controller"

TimeSyncController.bless()

export const getElements = () => {
  const wrapper = document.getElementById("test-time-sync")
  return { wrapper }
}

export const template = `
<div
  id="test-time-sync"
  data-controller="time-sync"
>
  <span
    data-target="time-sync.date"
    data-utc="1"
    data-unicode-format="h aaa"
  >
    1 AM
  </span>
  -
  <span
    data-target="time-sync.date"
    data-utc="2"
    data-unicode-format="h aaa"
  >
    11 PM
  </span>
  <span
    data-target="time-sync.date"
    data-utc="3"
    data-unicode-format="(zzz)"
  >(UTC)</span>
</ul>
`

export const createTemplateController = TemplateController(TimeSyncController, template, "#test-time-sync")

export const { registerController, unregisterController } = controllerRegistration(TimeSyncController, template)
