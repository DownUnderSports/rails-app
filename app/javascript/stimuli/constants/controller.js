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

  get disconnectPromises() {
    return this._disconnectPromises = this._disconnectPromises || []
  }

  nextDisconnect = () => new Promise(resolve => this.disconnectPromises.push(resolve))

  async connect() {
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
    const promises = this.disconnectPromises || []
    this._disconnectPromises = []
    promises.forEach(resolve => resolve())
  }
}
