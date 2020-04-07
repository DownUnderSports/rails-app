import { Controller } from "stimulus"
import { MDCTextField } from '@material/textfield';

export class TextFieldController extends Controller {
  static targets = [ "input", "label", "icon" ]
  connect() {
    this.textField = this.element
    if (this.element.classList.contains('text-field-with-input')) {
      this.textField.value = 'Input text';
    }
  }

  get textField() {
    return this._textField || (this.textField = this.element)
  }

  set textField(element) {
    this._textField = new MDCTextField(element)
  }
}
