import { Controller as StimulusController } from "stimulus"
import { Application } from "stimuli/constants/application"
import { isDebugOrEnv } from "helpers/is-env"

// export const ActiveControllers = {}

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

  async connect() {
    // let resolve
    // const promise = new Promise(r => resolve = r)
    // ActiveControllers[this] = {
    //   promise,
    //   resolve,
    // }

    isDebugOrEnv("development") && console.log(`connecting: ${this.identifier} - ${this.element}`)
    this._disconnected = false
    this.element["controllers"] = this.element["controllers"] || {}
    this.element["controllers"][this.identifier] = this
    this.connected && await this.connected()
  }

  async disconnect() {
    isDebugOrEnv("development") && console.log(`disconnecting: ${this.identifier} - ${this.element}`)
    this._disconnected = true
    try {
      delete this.element["controllers"][this.identifier]
    } catch(_) {}
    try {
      this.disconnected && await this.disconnected()
    } catch(err) {
      console.error(err)
    }
    // ActiveControllers[this] && ActiveControllers[this].resolve()
    // delete ActiveControllers[this]
  }
}
