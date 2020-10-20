import { Controller } from "stimuli/constants/controller"
import { MDCList } from '@material/list';
import { MDCRipple } from '@material/ripple';

export class ListController extends Controller {
  static keyName = "list"
  static targets = [ "list", "item" ]

  async connected() {
    this.list = this.listTarget
  }

  async disconnected(list, ripples) {
    if(!list) {
      list = this.list
      ripples = this.ripples
    }

    if(list) {
      for(let r = ripples.length; r > 0; r--) {
        await this.destroyRipple(ripples[r - 1])
      }
      await list.destroy()
    }
  }

  createRipple = (el) => {
    const ripple = new MDCRipple(el)
    this.ripples.push(ripple)
    return ripple
  }

  destroyRipple = async (ripple) => {
    await ripple.destroy()
    let idx
    while((idx = this.ripples.indexOf(ripple)) !== -1) {
      this.ripples.splice(idx, 1)
    }
  }

  get ripples () {
    return this._ripples || (this._ripples = [])
  }

  get list() {
    return this._list
  }

  set list(element) {
    if(this._list) this.disconnected(this._list, [...this.ripples])
    this._list = new MDCList(element)
    this.list.listElements.forEach(this.createRipple)
    this.list.singleSelection = true
  }
}
