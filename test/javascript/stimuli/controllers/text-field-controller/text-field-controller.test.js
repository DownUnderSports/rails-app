// stimuli/controllers/text-field-controller/text-field-controller.test.js
import { MDCTextField } from "@material/textfield";
import { TextFieldController } from "stimuli/controllers/text-field-controller"
import { sleepAsync } from "helpers/sleep-async"
import {
          createTemplateController,
          getElements,
          mockScope,
          registerController,
          template,
          unregisterController
                                      } from "./constants"

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TextFieldController", () => {

      it("has keyName 'text-field'", () => {
        expect(TextFieldController.keyName).toEqual("text-field")
      })

      it("has targets for input, label, and icon", () => {
        expect(TextFieldController.targets)
          .toEqual([ "input", "label", "icon" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [text-field] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["text-field"])
              .toBeInstanceOf(TextFieldController)
          })

          it("sets [textField] to an MDCTextField of element", () => {
            const { wrapper, input } = getElements(),
                  controller = wrapper["controllers"]["text-field"]

            expect(controller.textField).toBeInstanceOf(MDCTextField)
            expect(controller.textField.root_).toBe(wrapper)
            expect(controller.textField.input_).toBe(input)
          })
        })

        describe("on disconnect", () => {
          it("removes [text-field] from the element", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["text-field"]

            expect(wrapper["controllers"]["text-field"]).toBeInstanceOf(TextFieldController)

            await controller.disconnect()

            expect(wrapper["controllers"]["text-field"]).toBe(undefined)

            await controller.connect()
          })

          it("calls #destroy on .textField", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["text-field"],
                  textField = controller.textField,
                  destroy = textField.destroy,
                  mock = jest.fn()
                    .mockImplementation(destroy)
                    .mockName("destroy")

            Object.defineProperty(textField, "destroy", {
              value: mock,
              configurable: true
            })

            await controller.disconnect()

            expect(mock).toHaveBeenCalledTimes(1)
            expect(mock).toHaveBeenLastCalledWith()

            if(textField.hasOwnProperty("destroy")) delete textField.destroy

            await controller.connect()
          })
        })
      })

      describe("getters/setters", () => {
        describe("[value]", () => {
          it("is [textField][value] || ''", () => {
            let value
            const controller = new TextFieldController(),
                  textField = {},
                  getTextField = jest.fn().mockImplementation(() => textField),
                  setTextField = jest.fn().mockImplementation(() => textField),
                  getValue = jest.fn().mockImplementation(() => value),
                  setValue = jest.fn().mockImplementation(v => value = v)

            Object.defineProperty(controller, "textField", {
              get: getTextField,
              set: setTextField,
              configurable: true
            })

            Object.defineProperty(textField, "value", {
              get: getValue,
              set: setValue,
              configurable: true
            })

            const values = [
              "abcd",
              "1234",
              1234,
              [],
              {}
            ]

            let i = 0
            for(const v of values) {
              i++
              value = v

              expect(controller.value).toBe(v)
              expect(getTextField).toHaveBeenCalledTimes(i)
              expect(setTextField).not.toHaveBeenCalled()
              expect(getValue).toHaveBeenCalledTimes(i)
              expect(setValue).not.toHaveBeenCalled()
            }

            const falsy = [
              undefined,
              "",
              false,
              0
            ]

            for(const v of falsy) {
              i++
              value = v

              expect(controller.value).toBe("")
              expect(getTextField).toHaveBeenCalledTimes(i)
              expect(setTextField).not.toHaveBeenCalled()
              expect(getValue).toHaveBeenCalledTimes(i)
              expect(setValue).not.toHaveBeenCalled()
            }
          })

          it("is equal to the inputTarget value", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            controller.textField = wrapper
            controller.inputTarget.value = "test-input-match"

            expect(controller.value).toBe(controller.inputTarget.value)
            expect(controller.value).toEqual("test-input-match")
          })

          it("sets [textField][value]", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()

            controller.textField = wrapper

            let i = 0
            while(i < 20) {
              i++
              controller.textField.value = `test-input-${i}`
              expect(controller.value).toEqual(`test-input-${i}`)
              expect(controller.value).toBe(controller.textField.value)
            }
          })
        })

        describe("[textField]", () => {
          it("has no default", () => {
            const controller = new TextFieldController()

            expect(controller.textField).toBe(undefined)
          })

          it("requires an input child with the proper class", () => {
            const controller = new TextFieldController(),
                  div = document.createElement("div"),
                  input = document.createElement("input")

            expect(() => controller.textField = null).toThrow(TypeError)
            expect(() => controller.textField = null).toThrow(new TypeError("Cannot read property 'querySelector' of null"))

            expect(() => controller.textField = div).toThrow(TypeError)
            expect(() => controller.textField = div).toThrow(new TypeError("TextField Missing Input"))

            div.appendChild(input)

            expect(() => controller.textField = div).toThrow(TypeError)
            expect(() => controller.textField = div).toThrow(new TypeError("TextField Missing Input"))

            input.classList.add("mdc-text-field__input")

            expect(() => controller.textField = div).not.toThrow()
          })

          it("creates an MDCTextField of the given element", async () =>{
            const controller = createTemplateController(),
                  { wrapper, input } = getElements()

            controller.textField = wrapper

            expect(controller.textField).toBeInstanceOf(MDCTextField)
            expect(controller.textField.root_).toBe(wrapper)
            expect(controller.textField.input_).toBe(input)

            await controller.disconnect()
          })
        })
      })
    })
  })
})
