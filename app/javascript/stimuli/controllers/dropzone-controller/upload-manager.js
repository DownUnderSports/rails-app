import { DirectUpload } from "@rails/activestorage"
import { findElement, removeElement, insertAfter } from "helpers"
export { default as Dropzone } from "dropzone"

Dropzone.autoDiscover = false

export class UploadManager {
  constructor(source, file) {
    this.directUpload = new DirectUpload(file, source.url, this)
    this.source = source
    this.file = file
  }

  start() {
    this.file.controller = this
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
    input.name = this.source.inputTarget.name
    insertAfter(input, this.source.inputTarget)
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
    const element  = this.source.element,
          progress = event.loaded / event.total * 100,
          template = findElement(this.file.previewTemplate, ".dz-upload")

    template.style.width = `${progress}%`
  }

  emitDropzoneUploading = () => {
    this.file.status = Dropzone.UPLOADING
    this.source.dropZone.emit("processing", this.file)
  }

  emitDropzoneError = (error) => {
    this.file.status = Dropzone.ERROR
    this.source.dropZone.emit("error", this.file, error)
    this.source.dropZone.emit("complete", this.file)
  }

  emitDropzoneSuccess = () => {
    this.file.status = Dropzone.SUCCESS
    this.source.dropZone.emit("success", this.file)
    this.source.dropZone.emit("complete", this.file)
  }
}
