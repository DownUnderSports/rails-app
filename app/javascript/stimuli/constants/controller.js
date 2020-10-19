import { Controller as StimulusController } from "stimulus"
import { Application } from "stimuli/constants/application"
import { isDebugOrEnv } from "helpers/is-env"

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

  connect() {
    isDebugOrEnv("development") && console.log(`connecting: ${this.identifier} - ${this.element}`)
    this._disconnected = false
    this.element[this.identifier] = this
    this.connected && this.connected()
  }

  disconnect() {
    isDebugOrEnv("development") && console.log(`disconnecting: ${this.identifier} - ${this.element}`)
    this._disconnected = true
    try {
      delete this.element[this.identifier]
    } catch(_) {}
    this.disconnected && this.disconnected()
  }
}
