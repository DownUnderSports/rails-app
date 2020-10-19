import { Controller } from "stimuli/constants/controller"
import { MDCList } from '@material/list';
import { MDCRipple } from '@material/ripple';

export class ListController extends Controller {
  static keyName = "list"
  static targets = [ "list", "item" ]

  connected() {
    this.list = this.listTarget
  }

  disconnected() {
    if(this.list) {
      (this._ripples || []).forEach(this.destroyRipple)
      this.list.destroy()
    }
  }

  createRipple = (el) => {
    const ripple = new MDCRipple(el)
    this.ripples.push(ripple)
    return ripple
  }

  destroyRipple = (ripple) => {
    ripple.destroy()
    this.ripples.splice(this.ripples.indexOf(ripple), 1)
  }

  get ripples () {
    return this._ripples || (this._ripples || [])
  }

  get list() {
    return this._list
  }

  set list(element) {
    this._list && this.disconnected()
    this._list = new MDCList(element)
    this.list.listElements.forEach(this.createRipple)
    this.list.singleSelection = true
  }
}
