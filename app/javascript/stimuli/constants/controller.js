import { Controller as StimulusController } from "stimulus"
import { Application } from "stimuli"

export class Controller extends StimulusController {
  static registerController(value) {
    const key = value || this.keyName
    if(!key) throw new Error("Controller Key Required")

    Application.register(key, this)
  }

  static get keyName() {
    return this.hasOwnProperty('_keyName') ? this._keyName : void 0;
  }

  static set keyName(value) {
    this._keyName = value
  }
}
