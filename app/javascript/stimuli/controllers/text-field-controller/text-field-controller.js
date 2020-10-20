import { Controller } from "stimuli/constants/controller"
import { MDCTextField } from '@material/textfield';

export class TextFieldController extends Controller {
  static keyName = "text-field"
  static targets = [ "input", "label", "icon" ]

  async connected() {
    this.textField = this.element
  }

  async disconnected() {
    if(this.element) delete this.element.textField
    this.textField && await this.textField.destroy()
    this._textField = undefined
  }

  get value() {
    return this.textField.value || ''
  }

  set value(value) {
    this.textField.value = value || ''
    return this.value
  }

  get textField() {
    return this._textField
  }

  set textField(element) {
    if(element && element.querySelector("input.mdc-text-field__input")) {
      try { this._textField && this._textField.destroy() } catch(_) {}
      this._textField = new MDCTextField(element)
    } else throw new Error("TextField Missing Input")
  }
}
