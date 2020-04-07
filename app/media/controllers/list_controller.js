import { Controller } from "stimulus"
import { MDCList } from '@material/list';
import { MDCRipple } from '@material/ripple';

const isFocusedClass = 'mdc-ripple-upgraded--background-focused'

export class ListController extends Controller {
  static targets = [ "list", "item" ]

  connect() {
    this.list = this.listTarget
  }

  createRipple(el) {
    return new MDCRipple(el)
  }

  toggle(ev) {
    this.list.open
      ? this.close(ev)
      : this.open(ev)
  }

  get list() {
    return this._list || (this.list = this.listTarget)
  }

  set list(element) {
    this._list = new MDCList(element)
    this.list.listElements.map(this.createRipple)
    this.list.singleSelection = true
  }  
}
