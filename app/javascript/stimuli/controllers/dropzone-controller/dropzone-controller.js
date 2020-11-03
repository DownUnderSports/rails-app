import { Controller } from "stimuli/constants/controller"
import { default as Dropzone } from "dropzone"
import { UploadManager } from "./upload-manager"
import {
          getMetaValue,
          findElement,
          insertAfter,
          removeElement,
          sleepAsync
                          } from "helpers"

const dropzoneEvents = [
  "addedfile",
  "removedfile",
  "canceled",
  "processing",
  "queuecomplete"
]

export class DropzoneController extends Controller {
  static keyName = "dropzone"
  static targets = [ "dropzone", "input" ]

  async connected() {
    this.dropZone = new Dropzone(this.element, {
      url: this.url,
      headers: this.headers,
      maxFiles: this.maxFiles,
      maxFilesize: this.maxFileSize,
      acceptedFiles: this.acceptedFiles,
      addRemoveLinks: this.addRemoveLinks,
      autoQueue: false
    })
    this.hideFileInput()
    this.bindEvents()
  }

  async disconnected() {
    this.unbindEvents()
    this.showFileInput()
    this.dropZone && this.dropZone.destroy()
    this.dropZone = null
  }

// Private
  hideFileInput = () => {
    this._input = this.inputTarget
    this._inputDisplay = this.inputTarget.style.display
    this.inputTarget.controller = this
    this.inputTarget.disabled = true
    this.inputTarget.style.display = "none"
  }

  showFileInput = () => {
    if(this._input && this._input.controller === this) {
      this._input.disabled = false
      this._input.style.display = this._inputDisplay
      delete this._input.controller
      delete this._input
      delete this._inputDisplay
    }
  }

  onaddedfile = async (file) => {
    while(file.accepted === undefined) await sleepAsync()
    if(file.accepted) {
      const manager = new UploadManager(this, file)

      manager.start()
      return file
    }
  }

  onremovedfile = (file) =>
    file.manager && removeElement(file.manager.hiddenInput)

  oncanceled = (file) =>
    file.manager && file.manager.xhr.abort()

  onprocessing = () => {
    const submitButton = this.submitButton
    if(submitButton) submitButton.disabled = true
  }

  onqueuecomplete = () => {
    const submitButton = this.submitButton
    if(submitButton) submitButton.disabled = false
  }

  bindEvents = () =>
    dropzoneEvents.map(ev => this.dropZone.on(ev, this[`on${ev}`]))

  unbindEvents = () =>
    this.dropZone && this.dropZone.off()

  get headers() { return { "X-CSRF-Token": getMetaValue("csrf-token") } }

  get url() { return this.inputTarget.getAttribute("data-direct-upload-url") }

  get maxFiles() { return this.data.get("maxFiles") || 1 }

  get maxFileSize() { return this.data.get("maxFileSize") || 256 }

  get acceptedFiles() { return this.data.get("acceptedFiles") || null }

  get addRemoveLinks() {
    const value = this.data.get("addRemoveLinks")
    switch (value && value.toString().toLowerCase()) {
      case "0":
      case "f":
      case "false":
      case false:
        return false
      default:
        return true
    }
  }

  get form() { return this.element.closest("form") }

  get submitButton() {
    const form = this.form
    return form ? findElement(form, this.submitButtonQuery) : null
  }

  get submitButtonQuery() { return "input[type=submit], button[type=submit]" }

}
