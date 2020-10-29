// stimuli/controllers/text-field-controller/text-field-controller.test.js
import { MDCTextField } from "@material/textfield";
import { TextFieldController } from "stimuli/controllers/text-field-controller"
import { sleepAsync } from "test-helpers/sleep-async"
import { removeControllers } from "test-helpers/remove-controllers"
import {
          createTemplateController,
          getElements,
          mockScope,
          registerController,
          template
                                      } from "./constants"

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TextFieldController", () => {
      afterEach(removeControllers)

      it("has keyName 'text-field'", () => {
        expect(TextFieldController.keyName).toEqual("text-field")
      })

      it("has targets for input, label, and icon", () => {
        expect(TextFieldController.targets)
          .toEqual([ "input", "label", "icon" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)

        describe("on connect", () => {
          it("sets [text-field] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["text-field"])
              .toBeInstanceOf(TextFieldController)
          })

          it("sets [textField] to an MDCTextField of element", () => {
            const { wrapper, input } = getElements(),
                  controller = wrapper["controllers"]["text-field"]

            controller.testName = "sets [textField] to an MDCTextField of element"

            expect(controller.textField).toBeInstanceOf(MDCTextField)
            expect(controller.textField.root_).toBe(wrapper)
            expect(controller.textField.input_).toBe(input)
          })
        })

        describe("on disconnect", () => {
          it("removes [text-field] from the element", async () => {
            const { wrapper } = getElements()
            expect(wrapper["controllers"]["text-field"]).toBeInstanceOf(TextFieldController)
            wrapper["controllers"]["text-field"].testName = "removes [text-field] from the element"

            try {
              await wrapper["controllers"]["text-field"].disconnect()
            } catch(err) {
              console.error(err)
            }
            expect(wrapper["controllers"]["text-field"]).toBe(undefined)
          })

          it("calls #destroy on .textField", async () => {
            const { wrapper } = getElements(),
                  textField = wrapper["controllers"]["text-field"].textField,
                  destroy = textField.destroy,
                  mock = jest.fn()
                    .mockImplementation(destroy)
                    .mockName("destroy")

            wrapper["controllers"]["text-field"].testName = "calls #destroy on .textField"

            Object.defineProperty(textField, "destroy", {
              value: mock,
              configurable: true
            })

            await wrapper["controllers"]["text-field"].disconnect()

            expect(mock).toHaveBeenCalledTimes(1)
            expect(mock).toHaveBeenLastCalledWith()

            if(textField.hasOwnProperty("destroy")) delete textField.destroy
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

            controller.testName = "is [textField][value] || ''"

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
            controller.testName = "is equal to the inputTarget value"

            controller.textField = wrapper
            controller.inputTarget.value = "test-input-match"

            expect(controller.value).toBe(controller.inputTarget.value)
            expect(controller.value).toEqual("test-input-match")
          })

          it("sets [textField][value]", () => {
            const controller = createTemplateController(),
                  { wrapper } = getElements()
            controller.testName = "sets [textField][value]"

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
            controller.testName = "has no default"

            expect(controller.textField).toBe(undefined)
          })

          it("requires an input child with the proper class", () => {
            const controller = new TextFieldController(),
                  div = document.createElement("div"),
                  input = document.createElement("input")

            controller.testName = "requires an input child with the proper class"

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
