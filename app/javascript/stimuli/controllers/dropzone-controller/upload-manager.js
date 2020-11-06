import { DirectUpload } from "@rails/activestorage"
import { findElement, removeElement, insertAfter } from "helpers"
import { default as Dropzone } from "dropzone"

Dropzone.autoDiscover = false

export class UploadManager {
  constructor(controller, file) {
    this.directUpload = new DirectUpload(file, controller.url, this)
    this.controller = controller
    this.file = file
  }

  start() {
    this.file.manager = this
    this.hiddenInput = this.createHiddenInput()
    this.directUpload.create((error, attributes) => {
      if (error) {
        removeElement(this.hiddenInput)
        this.emitDropzoneError(error)
      } else {
        this.hiddenInput.value = attributes.signed_id
        this.emitDropzoneSuccess()
      }
    })
  }

// Private
  createHiddenInput = () => {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.controller.inputTarget.name
    insertAfter(input, this.controller.inputTarget)
    return input
  }

  directUploadWillStoreFileWithXHR = (xhr) => {
    this.bindProgressEvent(xhr)
    this.emitDropzoneUploading()
  }

  bindProgressEvent = (xhr) => {
    this.xhr = xhr
    this.xhr.upload.addEventListener("progress", this.uploadRequestDidProgress)
  }

  uploadRequestDidProgress = (event) => {
    const element  = this.controller.element,
          progress = event.loaded / event.total * 100,
          template = findElement(this.file.previewTemplate, ".dz-upload")

    template.style.width = `${progress}%`
  }

  emitDropzoneUploading = () => {
    this.file.status = Dropzone.UPLOADING
    this.controller.dropZone.emit("processing", this.file)
  }

  emitDropzoneError = (error) => {
    this.file.status = Dropzone.ERROR
    this.controller.dropZone.emit("error", this.file, error)
    this.controller.dropZone.emit("complete", this.file)
  }

  emitDropzoneSuccess = () => {
    this.file.status = Dropzone.SUCCESS
    this.controller.dropZone.emit("success", this.file)
    this.controller.dropZone.emit("complete", this.file)
  }
}
