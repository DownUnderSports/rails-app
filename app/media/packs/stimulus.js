import "@stimulus/polyfills"
import { Application } from "stimulus"
import { registerControllers } from "controllers"

export const StimulusApplication = Application.start()
registerControllers(StimulusApplication)
