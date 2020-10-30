/* "@stimulus/polyfills" */
import "core-js/features/array/find"
import "core-js/features/array/find-index"
import "core-js/features/array/from"
import "core-js/features/map"
import "core-js/features/object/assign"
import "core-js/features/promise"
import "core-js/features/set"
import "element-closest"
import "mutation-observer-inner-html-shim"
/* "@stimulus/polyfills" */

import { Application as StimulusApplication } from "stimulus"
// import StimulusReflex from "stimulus_reflex"

const uninitialized = !window._StimulusApplication

if(uninitialized) {
  window._StimulusApplication = StimulusApplication.start()
  // StimulusReflex.initialize(window._StimulusApplication)
}

export const Application = window._StimulusApplication
