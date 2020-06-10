// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.
import "@stimulus/polyfills"
import { Application as StimulusApplication } from "stimulus"
import StimulusReflex from "stimulus_reflex"

const uninitialized = !window._StimulusApplication

if(uninitialized) {
  window._StimulusApplication = StimulusApplication.start()
  StimulusReflex.initialize(window._StimulusApplication)
}

export const Application = window._StimulusApplication
