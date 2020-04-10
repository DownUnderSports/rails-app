import { Controller } from "stimulus"
import { MDCImageList } from '@material/list';
import { MDCRipple } from '@material/ripple';

export class ImageListController extends Controller {
  static targets = [ "list", "item" ]

  connect() {
    this.list = this.listTarget
  }

  disconnect() {
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
    this._list && this.disconnect()
    this._list = new MDCList(element)
    this.list.listElements.forEach(this.createRipple)
    this.list.singleSelection = true
  }
}
