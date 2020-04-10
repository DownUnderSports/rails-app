import { Controller } from "stimulus"
export { MDCCheckbox } from '@material/checkbox';

export class CheckboxController extends Controller {
  static targets = [ "nav-button", "title" ]

  connect() {
    this.checkbox = this.element
  }

  disconnect() {
    this.checkbox.destroy()
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
