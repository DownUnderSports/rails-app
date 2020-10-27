// stimuli/controllers/dropzone-controller/dropzone-controller.test.js
import { DropzoneController } from "stimuli/controllers/dropzone-controller"
import { default as Dropzone } from "dropzone"
import { removeControllers } from "test-helpers/remove-controllers"
import { getMetaValue } from "helpers/get-meta-value"
import { findElement } from "helpers/find-element"

jest.mock("helpers/get-meta-value")
jest.mock("helpers/find-element")
const { findElement: originalFindElement } = jest.requireActual("helpers/find-element")

getMetaValue.mockImplementation(v => `Meta Value: ${v}`)
findElement.mockImplementation(originalFindElement)

const getElements = () => {
  const wrapper = document.getElementById("dropzone-wrapper"),
        label = document.querySelector("label.label"),
        input = document.getElementById("image"),
        messageWrapper = document.getElementById("dropzone-message")

  return { wrapper, label, input, messageWrapper }
}
const dropzoneOn = Dropzone.prototype.on,
      dropzoneOff = Dropzone.prototype.off,
      mockDropzoneOn = jest.fn().mockImplementation(dropzoneOn),
      mockDropzoneOff = jest.fn().mockImplementation(dropzoneOff)

Dropzone.prototype.on = mockDropzoneOn
Dropzone.prototype.off = mockDropzoneOff

const clearMocks = () => {
  mockDropzoneOn.mockClear()
  mockDropzoneOff.mockClear()
  getMetaValue.mockClear()
}

const template = `
  <label
    for="image"
    class="label"
  >
    Image
  </label>
  <div
    id="dropzone-wrapper"
    data-controller="dropzone"
    data-dropzone-max-file-size="2"
    data-dropzone-max-files="1"
    data-target="dropzone.dropzone"
  >
    <input
      type="file"
      id="image"
      name="image"
      data-target="dropzone.input"
      data-direct-upload-url="/upload-file"
    />
    <div
      id="dropzone-message"
      class="dropzone-msg dz-message"
    >
      <h3 class="dropzone-msg-title">
        Drag here to upload or click here to browse
      </h3>
      <span class="dropzone-msg-desc">
        2 MB file size maximum. Allowed file types png, jpg.
      </span>
    </div>
  </div>
`

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
        beforeEach(() => {
          document.body.innerHTML = template
          DropzoneController.registerController()
        })
        afterEach(removeControllers)

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
                    calls = mockDropzoneOn.mock.calls.filter(([ name, _ ]) => event === name)

              if(boundEvents.indexOf(event) === -1) {
                expect(controller[`on${event}`]).toBe(undefined)

                for(let n = 0; n < calls.length; n++) {
                  const [ _, func ] = calls[n]

                  for (let key in controller) {
                    expect(controller[key]).not.toEqual(func)
                  }
                }
              }
              else {
                const [_, func ] = calls[calls.length - 1]
                expect(controller[`on${event}`]).toBeInstanceOf(Function)
                expect([2, 3]).toContain(calls.length)
                expect(mockDropzoneOn).toHaveBeenCalledWith(event, controller[`on${event}`])
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
          test.todo("on disconnect")
          it("removes [dropzone] from the element controllers", async () => {
            const { wrapper } = getElements()
            expect(wrapper["controllers"]["dropzone"]).toBeInstanceOf(DropzoneController)
            await wrapper["controllers"]["dropzone"].disconnect()
            expect(wrapper["controllers"]["dropzone"]).toBe(undefined)
          })

          it("unbinds dropzone events", async () => {
            const { wrapper } = getElements()

            await wrapper["controllers"]["dropzone"].disconnect()

            expect(mockDropzoneOff).toHaveBeenCalledTimes(1)
            expect(mockDropzoneOff).toHaveBeenCalledWith()
          })

          it("unhides the original inputTarget", async () => {
            const { wrapper, input } = getElements()

            await wrapper["controllers"]["dropzone"].disconnect()

            expect(input.controller).toBe(undefined)
            expect(input.disabled).toBe(false)
            expect(input.style.display).toBe("")
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
          })
        })
      })

      describe("getters", () => {
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

            class WrongError extends Error {}

            expect(() => controller.url).toThrow(TypeError)
            expect(() => controller.url).toThrow(new TypeError("Cannot read property 'getAttribute' of undefined"))

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
          beforeEach(() => {
            document.body.innerHTML = template
            DropzoneController.registerController()
          })
          afterEach(removeControllers)

          it("returns [data-dropzone-max-files] from element)", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"],
                  unitiatedController = new DropzoneController()

            expect(() => unitiatedController.maxFiles).toThrow(TypeError)
            expect(() => unitiatedController.maxFiles).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneMaxFiles = 5

            expect(controller.maxFiles).toBe("5")
            expect(controller.maxFiles).toBe(wrapper.dataset.dropzoneMaxFiles)
          })

          it("defaults to 1", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

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
          beforeEach(() => {
            document.body.innerHTML = template
            DropzoneController.registerController()
          })
          afterEach(removeControllers)

          it("returns [data-dropzone-max-file-size] from element)", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"],
                  unitiatedController = new DropzoneController()

            expect(() => unitiatedController.maxFileSize).toThrow(TypeError)
            expect(() => unitiatedController.maxFileSize).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneMaxFileSize = 5

            expect(controller.maxFileSize).toBe("5")
            expect(controller.maxFileSize).toBe(wrapper.dataset.dropzoneMaxFileSize)
          })

          it("defaults to 256", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

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
          beforeEach(() => {
            document.body.innerHTML = template
            DropzoneController.registerController()
          })
          afterEach(removeControllers)

          it("returns [data-dropzone-accepted-files] from element)", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"],
                  unitiatedController = new DropzoneController()

            expect(() => unitiatedController.acceptedFiles).toThrow(TypeError)
            expect(() => unitiatedController.acceptedFiles).toThrow(new TypeError("Cannot read property 'scope' of undefined"))

            wrapper.dataset.dropzoneAcceptedFiles = 5

            expect(controller.acceptedFiles).toBe("5")
            expect(controller.acceptedFiles).toBe(wrapper.dataset.dropzoneAcceptedFiles)
          })

          it("defaults to null", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

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
          beforeEach(() => {
            document.body.innerHTML = template
            DropzoneController.registerController()
          })
          afterEach(removeControllers)

          it("returns a boolean of [data-dropzone-add-remove-links] from element)", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"],
                  unitiatedController = new DropzoneController()

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
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dropzone"]

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

            form.appendChild(element)
            form.appendChild(button)
            form.appendChild(input)

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
            expect(findElement).toHaveBeenCalledTimes(1)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "submit"

            expect(controller.submitButton).toBe(button)
            expect(getElement).toHaveBeenCalledTimes(2)
            expect(findElement).toHaveBeenCalledTimes(2)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            input.type = "submit"

            expect(controller.submitButton).toBe(button)
            expect(getElement).toHaveBeenCalledTimes(3)
            expect(findElement).toHaveBeenCalledTimes(3)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "button"

            expect(controller.submitButton).toBe(input)
            expect(getElement).toHaveBeenCalledTimes(4)
            expect(findElement).toHaveBeenCalledTimes(4)
            expect(findElement).toHaveBeenLastCalledWith(form, "input[type=submit], button[type=submit]")

            button.type = "submit"
            form.removeChild(button)
            form.appendChild(button)

            expect(controller.submitButton).toBe(input)
            expect(getElement).toHaveBeenCalledTimes(5)
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
          test.todo(".onaddedfile")
        })

        describe(".onremovedfile", () => {
          test.todo(".onremovedfile")
        })

        describe(".oncanceled", () => {
          test.todo(".oncanceled")
        })

        describe(".onprocessing", () => {
          test.todo(".onprocessing")
        })

        describe(".onqueuecomplete", () => {
          test.todo(".onqueuecomplete")
        })
      })

      describe("actions", () => {
        describe(".hideFileInput", () => {
          test.todo(".hideFileInput")
        })
        describe(".showFileInput", () => {
          test.todo(".showFileInput")
        })
        describe(".bindEvents", () => {
          test.todo(".bindEvents")
        })
        describe(".unbindEvents", () => {
          test.todo(".unbindEvents")
        })
      })
    })
  })
})
