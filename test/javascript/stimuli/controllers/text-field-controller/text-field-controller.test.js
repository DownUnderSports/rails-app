// stimuli/controllers/text-field-controller/text-field-controller.test.js
import { MDCTextField } from "@material/textfield";
import { TextFieldController } from "stimuli/controllers/text-field-controller"
import { sleepAsync } from "test-helpers/sleep-async"
import { removeControllers } from "test-helpers/remove-controllers"

const getElements = () => {
  const wrapper = document.getElementById("test-text-field"),
        input = document.getElementById("test-email"),
        label = wrapper.querySelector("label"),
        icon = wrapper.querySelector("i")

  return { wrapper, input, label, icon }
}

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TextFieldController", () => {
      beforeEach(() => {
        document.body.innerHTML = `
          <div id="test-text-field" class="mdc-text-field" data-controller="text-field">
            <input id="test-email" data-target="text-field.input" class="mdc-text-field__input" />
            <i class="material-icons mdc-text-field__icon" data-target="text-field.icon">
              email
            </i>
            <label for="test-email" data-target="text-field.label">Email</label>
          </div>
        `
        TextFieldController.registerController()
      })
      afterEach(removeControllers)

      it("has keyName 'text-field'", () => {
        expect(TextFieldController.keyName).toEqual("text-field")
      })

      it("has targets for input, label, and icon", () => {
        expect(TextFieldController.targets)
          .toEqual([ "input", "label", "icon" ])
      })

      describe("on connect", () => {
        it("sets [text-field] to be the controller instance", () => {
          const { wrapper } = getElements()

          expect(wrapper["controllers"]["text-field"])
            .toBeInstanceOf(TextFieldController)
        })

        it("sets .textField to an MDCTextField of element", () => {
          const { wrapper, input } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          expect(controller.textField).toBeInstanceOf(MDCTextField)
          expect(controller.textField.root_).toBe(wrapper)
          expect(controller.textField.input_).toBe(input)
        })
      })

      describe("on disconnect", () => {
        it("removes [text-field] from the element", async () => {
          const { wrapper } = getElements()
          expect(wrapper["controllers"]["text-field"]).toBeInstanceOf(TextFieldController)
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

      describe(".value", () => {
        it("returns the value of .textField", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          try {
            let i = 0
            Object.defineProperty(controller, "textField", {
              configurable: true,
              value: {
                get value() {
                  return `test-value-${i}`
                }
              }
            })
            while(i < 20) {
              i++
              expect(controller.value).toEqual(`test-value-${i}`)
              expect(controller.value).toBe(controller.textField.value)
            }
          } finally {
            if(controller.hasOwnProperty("textField")) delete controller.textField
          }
        })

        it("is equal to the inputTarget value", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          controller.inputTarget.value = "test-input-match"

          expect(controller.value).toBe(controller.inputTarget.value)
          expect(controller.value).toEqual("test-input-match")
        })

        it("is an empty string if falsy", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]
          try {
            let i = 0
            Object.defineProperty(controller, "textField", {
              configurable: true,
              value: {
                get value() {
                  return null
                }
              }
            })
            while(i < 20) {
              i++
              expect(controller.value).toBe("")
              expect(controller.value).not.toBe(controller.textField.value)
            }
          } finally {
            if(controller.hasOwnProperty("textField")) delete controller.textField
          }
        })
      })

      describe(".value=", () => {
        it("sets the value of .textField", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          let i = 0
          while(i < 20) {
            i++
            controller.textField.value = `test-input-${i}`
            expect(controller.value).toEqual(`test-input-${i}`)
            expect(controller.value).toBe(controller.textField.value)
          }
        })

        it("returns the new value", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          let i = 0
          while(i < 20) {
            i++
            controller.textField.value = `test-input-${i}`
            expect(controller.value).toEqual(`test-input-${i}`)
            expect(controller.value).toBe(controller.inputTarget.value)
          }
        })
      })

      describe(".textField", () => {
        it("is an MDCTextField of element", () => {
          const { wrapper, input } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          expect(controller.textField).toBeInstanceOf(MDCTextField)
          expect(controller.textField.root_).toBe(wrapper)
          expect(controller.textField.input_).toBe(input)
        })

        it("returns [_textField]", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"],
                tf = controller._textField
          try {
            expect(controller.textField).toBe(controller._textField)

            controller._textField = "asdf"

            expect(controller.textField).toEqual("asdf")
          } finally {
            controller._textField = tf
          }
        })
      })

      describe(".textField=", () => {
        it("throws an error if missing input", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"]

          expect(() => { controller.textField = document.createElement("DIV") })
            .toThrow("TextField Missing Input")
        })

        it("sets .textField to an MDCTextField", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["text-field"],
                div = document.createElement("DIV")

          div.innerHTML = `
            <input id="test-email" data-target="text-field.input" class="mdc-text-field__input" />
          `

          expect(() => { controller.textField = div })
            .not.toThrow("TextField Missing Input")
        })
      })
    })
  })
})
