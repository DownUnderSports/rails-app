import { Controller } from "stimuli/constants/controller"
export { MDCCheckbox } from '@material/checkbox';

export class CheckboxController extends Controller {
  static keyName = "checkbox"
  static targets = [ "nav-button", "title" ]

  async connected() {
    this.checkbox = this.element
  }

  async disconnected() {
    this.checkbox && await this.checkbox.destroy()
  }

  get checked() {
    return this.checkbox.checked
  }

  set checked(state) {
    this.checkbox.checked = !!state
    return this.checked
  }

  get disabled() {
    return this.checkbox.disabled
  }

  set disabled(state) {
    this.checkbox.disabled = !!state
    return this.disabled
  }

  get indeterminate() {
    return this.checkbox.indeterminate
  }

  set indeterminate(state) {
    this.checkbox.indeterminate = !!state
    return this.indeterminate
  }

  get value() {
    return this.checkbox.value
  }

  set value(value) {
    this.checkbox.value = value
    return this.value
  }

  get checkbox() {
    return this._checkbox
  }

  set checkbox(element) {
    this._checkbox = new MDCCheckbox(element)
  }
}
