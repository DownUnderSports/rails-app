import { Controller } from "stimuli"
export { default as Dropzone } from "dropzone"
import { UploadManager } from "./upload-manager"
import { getMetaValue, findElement, removeElement, insertAfter } from "helpers"

const dropzoneEvents = [
  "addedfile",
  "removedfile",
  "canceled",
  "processing",
  "queuecomplete"
]
export class DropzoneController extends Controller {
  static targets = [ "input" ]

  connect() {
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

// Private
  hideFileInput = () => {
    this.inputTarget.disabled = true
    this.inputTarget.style.display = "none"
  }

  onaddedfile = (file) => {
    setTimeout(() => {
      if(file.accepted) {
        const manager = new UploadManager(this, file)

        manager.start()
      }
    }, 500)
  }

  onremovedfile = (file) =>
    file.controller && removeElement(file.controller.hiddenInput)

  oncanceled = (file) =>
    file.controller && file.controller.xhr.abort()

  onprocessing = () =>
    this.submitButton.disabled = true

  onqueuecomplete = () =>
    this.submitButton.disabled = false

  bindEvents = () =>
    dropZoneEvents.map(ev => this.dropZone.on(ev, this[`on${ev}`]))

  get headers() { return { "X-CSRF-Token": getMetaValue("csrf-token") } }

  get url() { return this.inputTarget.getAttribute("data-direct-upload-url") }

  get maxFiles() { return this.data.get("maxFiles") || 1 }

  get maxFileSize() { return this.data.get("maxFileSize") || 256 }

  get acceptedFiles() { return this.data.get("acceptedFiles") }

  get addRemoveLinks() { return this.data.get("addRemoveLinks") || true }

  get form() { return this.element.closest("form") }

  get submitButton() { return findElement(this.form, this.submitButtonQuery) }

  get submitButtonQuery() { return "input[type=submit], button[type=submit]" }

}
