// stimuli/controllers/dropzone-controller/upload-manager.js
import { UploadManager } from "stimuli/controllers/dropzone-controller/upload-manager"
import { DirectUpload } from "@rails/activestorage"
import { removeElement } from "helpers/remove-element"

jest.mock("helpers/remove-element")

const createUploadMock = jest.fn().mockImplementation((cb) => {
  cb(null, { signed_id: 'signedId' })
})

const createUploadMockWithError = jest.fn().mockImplementation((cb) => {
  cb(new Error("Test Error"), { signed_id: 'signedId' })
})

const originalCreate = DirectUpload.prototype.create

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("DropzoneController", () => {
      describe("helpers", () => {
        describe("UploadManager",() => {
          beforeEach(() => {
            Object.defineProperty(DirectUpload.prototype, "create", {
              value: createUploadMock,
              configurable: true,
              writable: true
            })
          })

          afterEach(() => {
            Object.defineProperty(DirectUpload.prototype, "create", {
              value: originalCreate,
              configurable: true,
              writable: true
            })
          })

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

            it("sets the given controller and file to matching properties", () => {
              const fakeController = { url: "test-url" },
                    fakeFile = {},
                    manager = new UploadManager(fakeController, fakeFile)

              expect(manager.controller).toBe(fakeController)
              expect(manager.file).toBe(fakeFile)
            })
          })

          describe("actions", () => {
            let manager, emptyfile

            beforeEach(() => {
              emptyfile = new File([], 'file')
              manager = new UploadManager({ url: "/fake-url" }, emptyfile)
            })

            describe(".start", () => {
              let input

              const otherFunctions = [
                      "directUploadWillStoreFileWithXHR",
                      "bindProgressEvent",
                      "uploadRequestDidProgress",
                      "emitDropzoneUploading",
                      "emitDropzoneError",
                      "emitDropzoneSuccess"
                    ]

              beforeEach(() => {
                for(const key of otherFunctions) {
                  Object.defineProperty(manager, key, {
                    value: jest.fn(),
                    writable: true,
                    configurable: true
                  })
                }

                Object.defineProperty(manager, "createHiddenInput", {
                  value: jest.fn().mockImplementation(() => input = document.createElement("input"))
                })
              })

              afterEach(() => {
                for(const key of otherFunctions) {
                  delete manager[key]
                }
                delete manager.createHiddenInput
                delete manager.hiddenInput
              })

              it("sets [file][manager] to [this]", () => {
                manager.start()
                expect(manager.file.manager).toBe(manager)
              })

              it("calls .createHiddenInput and assigns it to [hiddenInput]", () => {
                manager.start()

                expect(manager.hiddenInput).toBe(input)
                expect(manager.createHiddenInput).toHaveBeenCalledTimes(1)
                expect(manager.createHiddenInput).toHaveBeenLastCalledWith()
              })

              it("calls [directUpload].create with a callback function", () => {
                manager.start()

                expect(createUploadMock).toHaveBeenCalledTimes(1)
                expect(createUploadMock.mock.calls[0][0]).toBeInstanceOf(Function)
              })

              describe("on success", () => {
                it("the callback function sets [hiddenInput][value] to the signed_id", () => {
                  manager.start()

                  expect(input.value).toBe("signedId")
                })

                it("the callback function calls .emitDropzoneSuccess", () => {
                  manager.start()

                  expect(manager.emitDropzoneSuccess).toHaveBeenCalledTimes(1)
                  expect(manager.emitDropzoneSuccess).toHaveBeenLastCalledWith()
                })
              })

              describe("on error", () => {
                beforeEach(() => {
                  Object.defineProperty(DirectUpload.prototype, "create", {
                    value: createUploadMockWithError,
                    configurable: true,
                    writable: true
                  })
                })

                afterEach(() => {
                  Object.defineProperty(DirectUpload.prototype, "create", {
                    value: originalCreate,
                    configurable: true,
                    writable: true
                  })
                })

                it("the callback calls removeElement with [hiddenInput]", () => {
                  manager.start()

                  expect(removeElement).toHaveBeenCalledTimes(1)
                  expect(removeElement).toHaveBeenLastCalledWith(input)
                })

                it("the callback function calls .emitDropzoneError with the error", () => {
                  manager.start()

                  expect(manager.emitDropzoneError).toHaveBeenCalledTimes(1)
                  expect(manager.emitDropzoneError).toHaveBeenLastCalledWith(new Error("Test Error"))
                })
              })
            })

            describe(".createHiddenInput", () => {
              test.todo(".createHiddenInput")
            })

            describe(".directUploadWillStoreFileWithXHR", () => {
              test.todo(".directUploadWillStoreFileWithXHR")
            })

            describe(".bindProgressEvent", () => {
              test.todo(".bindProgressEvent")
            })

            describe(".uploadRequestDidProgress", () => {
              test.todo(".uploadRequestDidProgress")
            })

            describe(".emitDropzoneUploading", () => {
              test.todo(".emitDropzoneUploading")
            })

            describe(".emitDropzoneError", () => {
              test.todo(".emitDropzoneError")
            })

            describe(".emitDropzoneSuccess", () => {
              test.todo(".emitDropzoneSuccess")
            })
          })
        })
      })
    })
  })
})
