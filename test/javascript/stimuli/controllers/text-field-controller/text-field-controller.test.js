// stimuli/controllers/text-field-controller/text-field-controller.test.js
import { MDCTextField } from "@material/textfield";
import { TextFieldController } from "stimuli/controllers/text-field-controller"

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

      it("has keyName 'text-field'", () => {
        expect(TextFieldController.keyName).toEqual("text-field")
      })

      describe("on connect", () => {
        it("sets [text-field] to be the controller instance", () => {
          const el = document.getElementById("test-text-field")
          expect(el["text-field"]).toBeInstanceOf(TextFieldController)
        })

        it("sets .textField to an MDCTextField of element", () => {
          const el = document.getElementById("test-text-field"),
                input = document.getElementById("test-email")
          expect(el["text-field"].textField).toBeInstanceOf(MDCTextField)
          expect(el["text-field"].textField.root_).toBe(el)
          expect(el["text-field"].textField.input_).toBe(input)
        })
      })

      test.todo("on disconnect")
      test.todo(".value")
      test.todo(".value=")
      test.todo(".textField")
      test.todo(".textField=")
    })
  })
})
