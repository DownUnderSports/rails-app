// stimuli/controllers/dropzone-controller/dropzone-controller.js
import {
          createTemplateController,
          Dropzone,
          DropzoneController,
          dropzoneMockOff,
          dropzoneMockOn,
          findElement,
          findElementImplementation,
          getElements,
          getMetaValue,
          getMetaValueImplementation,
          registerController,
          removeElement,
          removeElementImplementation,
          sleepAsync,
          template,
          UploadManager,
          unregisterController
                                      } from "./_constants.dropzone-controller"

jest.mock("helpers/get-meta-value")
jest.mock("helpers/find-element")
jest.mock("helpers/remove-element")
jest.mock("stimuli/controllers/dropzone-controller/upload-manager")

getMetaValue.mockImplementation(getMetaValueImplementation)
findElement.mockImplementation(findElementImplementation)
removeElement.mockImplementation(removeElementImplementation)

const clearMocks = () => {
  dropzoneMockOn.mockClear()
  dropzoneMockOff.mockClear()
  getMetaValue.mockClear()
  findElement.mockClear()
  removeElement.mockClear()
  UploadManager.mockClear()
}

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("DropzoneController", () => {
      beforeEach(clearMocks)
      afterEach(clearMocks)

      it("has keyName 'dropzone'", () => {
        expect(DropzoneController.keyName).toEqual("dropzone")
      })

      it("has targets for dropzone and item(s)", () => {
        expect(DropzoneController.targets)
          .toEqual([ "dropzone", "input" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [dropzone] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["dropzone"])
              .toBeInstanceOf(DropzoneController)
          })

          it("sets [dropZone] to a new Dropzone of element", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            expect(controller.dropZone).toBeInstanceOf(Dropzone)
            expect(controller.dropZone.element).toBe(wrapper)

            const options = [
              [ "url",            controller.url ],
              [ "headers",        controller.headers ],
              [ "maxFiles",       controller.maxFiles ],
              [ "maxFilesize",    controller.maxFileSize ],
              [ "acceptedFiles",  controller.acceptedFiles ],
              [ "addRemoveLinks", controller.addRemoveLinks ],
              [ "autoQueue",      false ]
            ]

            for (let i = 0; i < options.length; i++) {
              const [ key, value ] = options[i]

              expect(controller.dropZone.options[key]).toStrictEqual(value)
            }
          })

          it("binds file change listeners", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            const boundEvents = [
              "addedfile",
              "removedfile",
              "canceled",
              "processing",
              "queuecomplete"
            ]

            let called = 0

            for (let i = 0; i < controller.dropZone.events.length; i++) {
              const event = controller.dropZone.events[i],
                    calls = dropzoneMockOn.mock.calls.filter(([ name, _ ]) => event === name)

              if(boundEvents.indexOf(event) === -1) {
                expect(controller[`on${event}`]).toBe(undefined)

                for(let n = 0; n < calls.length; n++) {
                  const [ _, func ] = calls[n]

                  for (let key in controller) {
                    expect(controller[key]).not.toEqual(func)
                  }
                }
              } else {
                const [_, func ] = calls[calls.length - 1]
                expect(controller[`on${event}`]).toBeInstanceOf(Function)
                expect([2, 3]).toContain(calls.length)
                expect(dropzoneMockOn).toHaveBeenCalledWith(event, controller[`on${event}`])
                expect(func).toBe(controller[`on${event}`])
                ++called
              }
            }
            expect(called).toBe(boundEvents.length)
          })

          it("hides [inputTarget]", () => {
            const { wrapper, input } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            expect(controller.inputTarget).toBe(input)

            expect(input.controller).toBe(controller)
            expect(input.disabled).toBe(true)
            expect(input.style.display).toBe("none")
          })

          it("caches [inputTarget] for disconnect unbinding", () => {
            const { wrapper, input } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            expect(controller._input).toBe(input)
          })
        })

        describe("on disconnect", () => {
          it("removes [dropzone] from the element controllers", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            expect(wrapper["controllers"]["dropzone"]).toBeInstanceOf(DropzoneController)
            await controller.disconnect()
            expect(wrapper["controllers"]["dropzone"]).toBe(undefined)

            await controller.connect()
          })

          it("unbinds dropzone events", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            await controller.disconnect()

            expect(dropzoneMockOff).toHaveBeenCalledTimes(1)
            expect(dropzoneMockOff).toHaveBeenCalledWith()

            await controller.connect()
          })

          it("unhides the original inputTarget", async () => {
            const { wrapper, input } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

            await controller.disconnect()

            expect(input.controller).toBe(undefined)
            expect(input.disabled).toBe(false)
            expect(input.style.display).toBe("")

            await controller.connect()
          })

          it("destroys [dropZone]", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"],
                  dropZone = controller.dropZone,
                  destroy = dropZone.destroy,
                  mockDestroy = jest.fn().mockImplementation(destroy)

            try {
              Object.defineProperty(dropZone, "destroy", {
                value: mockDestroy,
                writable: true,
                configurable: true
              })

              expect(dropZone.destroy).not.toHaveBeenCalled()

              await controller.disconnect()

              expect(dropZone.destroy).toHaveBeenCalledTimes(1)
              expect(controller.dropZone).toBe(null)
            } finally {
              if(dropZone.hasOwnProperty("destroy")) delete dropZone.destroy
            }

            await controller.connect()
          })
        })
      })

      describe("getters/setters", () => {
        describe("[headers]", () => {
          it("returns a header object with the result of getMetaValue('csrf-token')", () => {
            const controller = new DropzoneController()

            expect(getMetaValue).not.toHaveBeenCalled()
            expect(controller.headers).toStrictEqual({ "X-CSRF-Token": "Meta Value: csrf-token" })
            expect(getMetaValue).toHaveBeenCalledTimes(1)
            expect(getMetaValue).toHaveBeenLastCalledWith("csrf-token")
          })
        })

        describe("[url]", () => {
          it("returns [data-direct-upload-url] from inputTarget)", () => {
            const controller = new DropzoneController(),
                  input = document.createElement("input")

            expect(() => controller.url).toThrow(TypeError)
            expect(() => controller.url).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            Object.defineProperty(controller, "inputTarget", {
              value: input,
              writable: true,
              configurable: true
            })

            expect(controller.url).toBe(null)

            input.dataset.directUploadUrl = "/direct-upload-url"
            expect(controller.url).toBe(input.dataset.directUploadUrl)
            expect(controller.url).toBe("/direct-upload-url")
          })
        })

        describe("[maxFiles]", () => {
          it("returns [data-dropzone-max-files] from element)", () => {
            const controller = createTemplateController(),
                  unitiatedController = new DropzoneController(),
                  { wrapper } = getElements()

            expect(() => unitiatedController.maxFiles).toThrow(TypeError)
            expect(() => unitiatedController.maxFiles).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneMaxFiles = 5

            expect(controller.maxFiles).toBe("5")
            expect(controller.maxFiles).toBe(wrapper.dataset.dropzoneMaxFiles)
          })

          it("defaults to 1", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            wrapper.removeAttribute("data-dropzone-max-files")

            expect(controller.maxFiles).toBe(1)
            expect(controller.data.get("maxFiles")).toBe(null)
          })

          it("is a wrapper for [data].get('maxFiles')", () => {
            const controller = new DropzoneController()

            let dataValue = { value: 10 }

            Object.defineProperty(controller, "data", {
              value: {
                get: jest.fn().mockImplementation(() => dataValue)
              },
              configurable: true,
              writable: true
            })

            expect(controller.maxFiles).toBe(dataValue)
            expect(controller.data.get).toHaveBeenCalledTimes(1)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFiles")

            expect(controller.maxFiles).toEqual({ value: 10 })
            expect(controller.data.get).toHaveBeenCalledTimes(2)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFiles")

            dataValue = null

            expect(controller.maxFiles).toBe(1)
            expect(controller.data.get).toHaveBeenCalledTimes(3)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFiles")
          })
        })

        describe("[maxFileSize]", () => {
          it("returns [data-dropzone-max-file-size] from element)", () => {
            const controller = createTemplateController(),
                  unitiatedController = new DropzoneController(),
                  { wrapper } = getElements()

            expect(() => unitiatedController.maxFileSize).toThrow(TypeError)
            expect(() => unitiatedController.maxFileSize).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneMaxFileSize = 5

            expect(controller.maxFileSize).toBe("5")
            expect(controller.maxFileSize).toBe(wrapper.dataset.dropzoneMaxFileSize)
          })

          it("defaults to 256", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            wrapper.removeAttribute("data-dropzone-max-file-size")

            expect(controller.maxFileSize).toBe(256)
            expect(controller.data.get("maxFileSize")).toBe(null)
          })

          it("is a wrapper for [data].get('maxFileSize')", () => {
            const controller = new DropzoneController()

            let dataValue = { value: 10 }

            Object.defineProperty(controller, "data", {
              value: {
                get: jest.fn().mockImplementation(() => dataValue)
              },
              configurable: true,
              writable: true
            })

            expect(controller.maxFileSize).toBe(dataValue)
            expect(controller.data.get).toHaveBeenCalledTimes(1)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFileSize")

            expect(controller.maxFileSize).toEqual({ value: 10 })
            expect(controller.data.get).toHaveBeenCalledTimes(2)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFileSize")

            dataValue = null

            expect(controller.maxFileSize).toBe(256)
            expect(controller.data.get).toHaveBeenCalledTimes(3)
            expect(controller.data.get).toHaveBeenLastCalledWith("maxFileSize")
          })
        })

        describe("[acceptedFiles]", () => {
          it("returns [data-dropzone-accepted-files] from element)", () => {
            const controller = createTemplateController(),
                  unitiatedController = new DropzoneController(),
                  { wrapper } = getElements()

            expect(() => unitiatedController.acceptedFiles).toThrow(TypeError)
            expect(() => unitiatedController.acceptedFiles).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneAcceptedFiles = 5

            expect(controller.acceptedFiles).toBe("5")
            expect(controller.acceptedFiles).toBe(wrapper.dataset.dropzoneAcceptedFiles)
          })

          it("defaults to null", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            wrapper.removeAttribute("data-dropzone-accepted-files")

            expect(controller.acceptedFiles).toBe(null)
            expect(controller.data.get("acceptedFiles")).toBe(null)

            wrapper.setAttribute("data-dropzone-accepted-files", "")

            expect(controller.acceptedFiles).toBe(null)
            expect(controller.data.get("acceptedFiles")).toBe("")
          })

          it("is a wrapper for [data].get('acceptedFiles')", () => {
            const controller = new DropzoneController()

            let dataValue = { value: 10 }

            Object.defineProperty(controller, "data", {
              value: {
                get: jest.fn().mockImplementation(() => dataValue)
              },
              configurable: true,
              writable: true
            })

            expect(controller.acceptedFiles).toBe(dataValue)
            expect(controller.data.get).toHaveBeenCalledTimes(1)
            expect(controller.data.get).toHaveBeenLastCalledWith("acceptedFiles")

            expect(controller.acceptedFiles).toEqual({ value: 10 })
            expect(controller.data.get).toHaveBeenCalledTimes(2)
            expect(controller.data.get).toHaveBeenLastCalledWith("acceptedFiles")

            dataValue = null

            expect(controller.acceptedFiles).toBe(null)
            expect(controller.data.get).toHaveBeenCalledTimes(3)
            expect(controller.data.get).toHaveBeenLastCalledWith("acceptedFiles")

            dataValue = ""

            expect(controller.acceptedFiles).toBe(null)
            expect(controller.data.get).toHaveBeenCalledTimes(4)
            expect(controller.data.get).toHaveBeenLastCalledWith("acceptedFiles")
          })
        })

        describe("[addRemoveLinks]", () => {
          it("returns a boolean of [data-dropzone-add-remove-links] from element)", () => {
            const controller = createTemplateController(),
                  unitiatedController = new DropzoneController(),
                  { wrapper } = getElements()

            expect(() => unitiatedController.addRemoveLinks).toThrow(TypeError)
            expect(() => unitiatedController.addRemoveLinks).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            const falsy = [ 0, "0", "f", "F", "false", "FALSE", false ]

            for(let i = 0; i < falsy.length; i++) {
              wrapper.dataset.dropzoneAddRemoveLinks = falsy[i]

              expect(controller.addRemoveLinks).toBe(false)
            }

            const truthy = [ 1, "1", 5, "5", "asdf", true, "t", "true", "T", "TRUE" ]

            for(let i = 0; i < truthy.length; i++) {
              wrapper.dataset.dropzoneAddRemoveLinks = truthy[i]

              expect(controller.addRemoveLinks).toBe(true)
            }

          })

          it("defaults to true", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            wrapper.removeAttribute("data-dropzone-add-remove-links")

            expect(controller.addRemoveLinks).toBe(true)
            expect(controller.data.get("addRemoveLinks")).toBe(null)
          })

          it("is a wrapper for [data].get('addRemoveLinks')", () => {
            const controller = new DropzoneController()

            let dataValue = { value: 10 }

            Object.defineProperty(controller, "data", {
              value: {
                get: jest.fn().mockImplementation(() => dataValue)
              },
              configurable: true,
              writable: true
            })

            expect(controller.addRemoveLinks).toBe(true)
            expect(controller.data.get).toHaveBeenCalledTimes(1)
            expect(controller.data.get).toHaveBeenLastCalledWith("addRemoveLinks")

            expect(controller.addRemoveLinks).toEqual(true)
            expect(controller.data.get).toHaveBeenCalledTimes(2)
            expect(controller.data.get).toHaveBeenLastCalledWith("addRemoveLinks")

            dataValue = null

            expect(controller.addRemoveLinks).toBe(true)
            expect(controller.data.get).toHaveBeenCalledTimes(3)
            expect(controller.data.get).toHaveBeenLastCalledWith("addRemoveLinks")

            dataValue = false

            expect(controller.addRemoveLinks).toBe(false)
            expect(controller.data.get).toHaveBeenCalledTimes(4)
            expect(controller.data.get).toHaveBeenLastCalledWith("addRemoveLinks")
          })
        })

        describe("[form]", () => {
          it("is a wrapper for [element].closest('form')", () => {
            const controller = new DropzoneController(),
                  element = document.createElement("element"),
                  form = document.createElement("form"),
                  middle = document.createElement("div"),
                  outerForm = document.createElement("form"),
                  getElement = jest.fn().mockImplementation(() => element),
                  originalClosest = element.closest.bind(element),
                  closest = jest.fn().mockImplementation(str => originalClosest(str))

            outerForm.appendChild(form)
            form.appendChild(middle)
            middle.appendChild(element)

            Object.defineProperty(controller, "element", {
              get: getElement,
              set: value => Object.defineProperty(controller, "element", {
                value,
                writable: true,
                configurable: true
              }),
              configurable: true,
            })

            Object.defineProperty(element, "closest", {
              value: closest,
              configurable: true,
              writable: true
            })

            expect(controller.form).toBe(form)
            expect(getElement).toHaveBeenCalledTimes(1)
            expect(closest).toHaveBeenCalledTimes(1)
            expect(closest).toHaveBeenLastCalledWith("form")
          })
        })

        describe("[submitButton]", () => {
          it("calls findElement() with [form] and [submitButtonQuery]", () => {
            const controller = new DropzoneController(),
                  element = document.createElement("element"),
                  form = document.createElement("form"),
                  button = document.createElement("button"),
                  input = document.createElement("input"),
                  getElement = jest.fn().mockImplementation(() => element)

            Object.defineProperty(controller, "element", {
              get: getElement,
              set: value => Object.defineProperty(controller, "element", {
                value,
                writable: true,
                configurable: true
              }),
              configurable: true,
            })

            expect(controller.submitButton).toBe(null)
            expect(getElement).toHaveBeenCalledTimes(1)
            expect(findElement).not.toHaveBeenCalled()

            form.appendChild(element)
            form.appendChild(button)
            form.appendChild(input)

            expect(controller.submitButton).toBe(null)
            expect(getElement).toHaveBeenCalledTimes(2)
            expect(findElement).toHaveBeenCalledTimes(1)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "submit"

            expect(controller.submitButton).toBe(button)
            expect(getElement).toHaveBeenCalledTimes(3)
            expect(findElement).toHaveBeenCalledTimes(2)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            input.type = "submit"

            expect(controller.submitButton).toBe(button)
            expect(getElement).toHaveBeenCalledTimes(4)
            expect(findElement).toHaveBeenCalledTimes(3)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "button"

            expect(controller.submitButton).toBe(input)
            expect(getElement).toHaveBeenCalledTimes(5)
            expect(findElement).toHaveBeenCalledTimes(4)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "submit"
            form.removeChild(button)
            form.appendChild(button)

            expect(controller.submitButton).toBe(input)
            expect(getElement).toHaveBeenCalledTimes(6)
            expect(findElement).toHaveBeenCalledTimes(5)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")
          })
        })

        describe("[submitButtonQuery]", () => {
          it("is a querySelector string for submit inputs and buttons", () => {
            const controller = new DropzoneController()

            expect(controller.submitButtonQuery).toBe("input[type=submit], button[type=submit]")
          })
        })
      })

      describe("listeners", () => {
        describe(".onaddedfile", () => {
          it("expects a file object", async () => {
            await expect(new DropzoneController().onaddedfile())
                    .rejects
                    .toThrow(TypeError)

            await expect(new DropzoneController().onaddedfile())
                    .rejects
                    .toThrow(new TypeError("Cannot read property 'accepted' of undefined"))
          })

          it("waits for the file object to be accepted or rejected", async () => {
            let done = false
            const file = {},
                  rejected = new DropzoneController()
                    .onaddedfile(file)
                    .then((value) => { done = true; return value })

            let i = 0
            while(file.accepted === undefined) {
              expect(done).toBe(false)
              if(++i > 99) file.accepted = false
              await sleepAsync()
            }

            expect(done).toBe(true)
            expect(await rejected).toBe(undefined)
            expect(i).toBe(100)

            done = false
            delete file.accepted
            const accepted = new DropzoneController()
              .onaddedfile(file)
              .then((value) => { done = true; return value })

            i = 0
            while(file.accepted === undefined) {
              expect(done).toBe(false)
              if(++i > 99) file.accepted = true
              await sleepAsync()
            }

            expect(done).toBe(true)
            expect(await accepted).toBe(file)
            expect(i).toBe(100)
          })

          it("calls start on a new UploadManager if file is accepted", async () => {
            let done = false
            const file = { accepted: true },
                  controller = new DropzoneController()

            await controller.onaddedfile(file)

            expect(UploadManager).toHaveBeenCalledTimes(1)
            expect(UploadManager).toHaveBeenNthCalledWith(1, controller, file)

            expect(UploadManager.mock.instances.length).toBe(1)
            const uploaderInstance = UploadManager.mock.instances[0]
            expect(uploaderInstance.start).toHaveBeenCalledTimes(1)
            expect(uploaderInstance.start).toHaveBeenNthCalledWith(1)
          })

          it("does nothing if file is rejected", async () => {
            let done = false
            const file = { accepted: false },
                  controller = new DropzoneController()

            await controller.onaddedfile(file)

            expect(UploadManager).not.toHaveBeenCalled()
            expect(UploadManager.mock.instances.length).toBe(0)
          })
        })

        describe(".onremovedfile", () => {
          it("expects an file object with [manager] assigned", () => {
            expect(() => new DropzoneController().onremovedfile())
              .toThrow(TypeError)

            expect(() => new DropzoneController().onremovedfile())
              .toThrow(new TypeError("Cannot read property 'manager' of undefined"))
          })

          it("calls removeElement with the UploadManager [hiddenInput] property", async () => {
            let done = false
            const manager = {},
                  input = document.createElement("INPUT"),
                  getInput = jest.fn().mockImplementation(() => input),
                  setInput = jest.fn(),
                  file = {},
                  getManager = jest.fn().mockImplementation(() => manager),
                  setManager = jest.fn(),
                  controller = new DropzoneController()

            Object.defineProperty(manager, "hiddenInput", {
              get: getInput,
              set: setInput
            })

            Object.defineProperty(file, "manager", {
              get: getManager,
              set: setManager
            })

            await controller.onremovedfile(file)

            expect(getManager).toHaveBeenCalledTimes(2)
            expect(setManager).not.toHaveBeenCalled()
            expect(getInput).toHaveBeenCalledTimes(1)
            expect(setInput).not.toHaveBeenCalled()
            expect(removeElement).toHaveBeenCalledTimes(1)
            expect(removeElement).toHaveBeenNthCalledWith(1, input)
          })
        })

        describe(".oncanceled", () => {
          it("expects an file object with [manager] assigned", () => {
            expect(() => new DropzoneController().oncanceled())
              .toThrow(TypeError)

            expect(() => new DropzoneController().oncanceled())
              .toThrow(new TypeError("Cannot read property 'manager' of undefined"))
          })

          it("calls abort on the UploadManager [xhr] property", async () => {
            let done = false
            const manager = {},
                  xhr = { abort: jest.fn() },
                  getXhr = jest.fn().mockImplementation(() => xhr),
                  setXhr = jest.fn(),
                  file = {},
                  getManager = jest.fn().mockImplementation(() => manager),
                  setManager = jest.fn(),
                  controller = new DropzoneController()

            Object.defineProperty(manager, "xhr", {
              get: getXhr,
              set: setXhr
            })

            Object.defineProperty(file, "manager", {
              get: getManager,
              set: setManager
            })

            await controller.oncanceled(file)

            expect(getManager).toHaveBeenCalledTimes(2)
            expect(setManager).not.toHaveBeenCalled()
            expect(getXhr).toHaveBeenCalledTimes(1)
            expect(setXhr).not.toHaveBeenCalled()
            expect(xhr.abort).toHaveBeenCalledTimes(1)
            expect(xhr.abort).toHaveBeenNthCalledWith(1)
          })
        })

        describe(".onprocessing", () => {
          it("sets [submitButton][disabled] to true if exists", async () => {
            let submitButton = undefined
            const controller = new DropzoneController(),
                  getSubmitButton = jest.fn().mockImplementation(() => submitButton)

            Object.defineProperty(controller, "submitButton", {
              get: getSubmitButton
            })

            expect(controller.onprocessing).not.toThrow()
            expect(getSubmitButton).toHaveBeenCalledTimes(1)

            submitButton = {}
            expect(controller.onprocessing).not.toThrow()
            expect(getSubmitButton).toHaveBeenCalledTimes(2)
            expect(submitButton.disabled).toBe(true)
          })
        })

        describe(".onqueuecomplete", () => {
          it("sets [submitButton][disabled] to false if exists", async () => {
            let submitButton = undefined
            const controller = new DropzoneController(),
                  getSubmitButton = jest.fn().mockImplementation(() => submitButton)

            Object.defineProperty(controller, "submitButton", {
              get: getSubmitButton
            })

            expect(controller.onqueuecomplete).not.toThrow()
            expect(getSubmitButton).toHaveBeenCalledTimes(1)

            submitButton = {}
            expect(controller.onqueuecomplete).not.toThrow()
            expect(getSubmitButton).toHaveBeenCalledTimes(2)
            expect(submitButton.disabled).toBe(false)
          })
        })
      })

      describe("actions", () => {
        describe(".hideFileInput", () => {
          it("caches and hides and disables [inputTarget]", async () => {
            const basicController = new DropzoneController(),
                  controller = createTemplateController(),
                  { input } = getElements()

            expect(basicController.hideFileInput).toThrow(TypeError)
            expect(basicController.hideFileInput).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            expect(input.controller).toBe(undefined)
            expect(input.disabled).toBe(false)
            expect(input.style.display).toBe("")

            expect(controller.hideFileInput).not.toThrow()
            expect(input.controller).toBe(controller)
            expect(input.disabled).toBe(true)
            expect(input.style.display).toBe("none")
          })
        })
        describe(".showFileInput", () => {
          it("uncaches and unhides [_input] after .hideFileInput", async () => {
            const basicController = new DropzoneController(),
                  controller = createTemplateController(),
                  { input } = getElements()

            input.disabled = true
            input.style.display = "none"

            expect(basicController.showFileInput).not.toThrow()

            expect(input.disabled).toBe(true)
            expect(input.style.display).toBe("none")

            expect(controller.showFileInput).not.toThrow()
            expect(input.disabled).toBe(true)
            expect(input.style.display).toBe("none")

            input.style.display = "flex"
            controller.hideFileInput()
            expect(input.style.display).toBe("none")

            expect(controller.showFileInput).not.toThrow()
            expect(input.disabled).toBe(false)
            expect(input.style.display).toBe("flex")

            controller.hideFileInput()
            expect(input.style.display).toBe("none")

            input.controller = null

            expect(controller.showFileInput).not.toThrow()
            expect(input.disabled).toBe(true)
            expect(input.style.display).toBe("none")

            input.controller = controller

            expect(controller.showFileInput).not.toThrow()
            expect(input.disabled).toBe(false)
            expect(input.style.display).toBe("flex")
          })
        })

        describe(".bindEvents", () => {
          it("expects [dropZone] to have been set", () => {
            expect(() => new DropzoneController().bindEvents())
              .toThrow(TypeError)

            expect(() => new DropzoneController().bindEvents())
              .toThrow(new TypeError("Cannot read property 'on' of undefined"))
          })

          it("calls [dropZone].on with each on{event} listener", () => {
            const controller = new DropzoneController(),
                  eventList = [
                    "addedfile",
                    "removedfile",
                    "canceled",
                    "processing",
                    "queuecomplete"
                  ]

            controller.dropZone = {
              on: jest.fn()
            }

            expect(controller.bindEvents).not.toThrow()
            expect(controller.dropZone.on).toHaveBeenCalledTimes(5)
            for(let i = 0; i < eventList.length; i++) {
              const name = eventList[i],
                    func = controller[`on${name}`]
              expect(func).toBeInstanceOf(Function)
              expect(controller.dropZone.on).toHaveBeenCalledWith(name, func)
            }
          })
        })

        describe(".unbindEvents", () => {
          test.todo(".unbindEvents")
          it("does not expect [dropZone] to be set", () => {
            expect(() => new DropzoneController().unbindEvents()).not.toThrow()
          })

          it("calls [dropZone].off", () => {
            const controller = new DropzoneController(),
                  eventList = [
                    "addedfile",
                    "removedfile",
                    "canceled",
                    "processing",
                    "queuecomplete"
                  ]

            controller.dropZone = {
              off: jest.fn()
            }

            expect(controller.unbindEvents).not.toThrow()
            expect(controller.dropZone.off).toHaveBeenCalledTimes(1)
            expect(controller.dropZone.off).toHaveBeenNthCalledWith(1)
          })
        })
      })
    })
  })
})
