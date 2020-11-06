// stimuli/controllers/dropzone-controller/upload-manager.js
import { UploadManager } from "stimuli/controllers/dropzone-controller/upload-manager"
import { DirectUpload } from "@rails/activestorage"

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("DropzoneController", () => {
      describe("helpers", () => {
        describe("UploadManager",() => {
          test.todo("write tests for stimuli/controllers/dropzone-controller/upload-manager.js")

          describe("constructor", () => {
            it("attaches a new DirectUpload using the given controller[url], file, and [this]", () => {
              expect(() => new UploadManager()).toThrow(TypeError)
              expect(() => new UploadManager()).toThrow(new TypeError("Cannot read property 'url' of undefined"))

              const fakeController = { url: "test-url" },
                    fakeFile = {},
                    manager = new UploadManager(fakeController, fakeFile)

              expect(manager.directUpload).toBeInstanceOf(DirectUpload)
              expect(manager.directUpload.file).toBe(fakeFile)
              expect(manager.directUpload.url).toBe(fakeController.url)
              expect(manager.directUpload.delegate).toBe(manager)
            })

            it("the given controller and file to matching properties", () => {
              const fakeController = { url: "test-url" },
                    fakeFile = {},
                    manager = new UploadManager(fakeController, fakeFile)

              expect(manager.controller).toBe(fakeController)
              expect(manager.file).toBe(fakeFile)
            })
          })
        })
      })
    })
  })
})
