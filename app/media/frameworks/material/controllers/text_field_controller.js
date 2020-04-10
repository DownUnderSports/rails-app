import { Controller } from "stimulus"
import { MDCTextField } from '@material/textfield';

export class TextFieldController extends Controller {
  static targets = [ "input", "label", "icon" ]

  connect() {
    this.textField = this.element
  }

  disconnect() {
    this.textField.destroy()
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
    this._textField = new MDCTextField(element)
  }
}
