import { Controller } from "stimuli/constants/controller"
import { MDCTopAppBar } from '@material/top-app-bar';

export class TopBarController extends Controller {
  static keyName = "top-bar"
  static targets = [ "nav-button", "title" ]
  connected() {
    this.topBar = this.element
  }

  disconnected() {
    if(this.element) delete this.element.topBar
    try {
      this.topBar && this.topBar.destroy()
    } catch(_) {}
    this._topBar = undefined
  }

  get topBar() {
    return this._topBar
  }

  set topBar(element) {
    this._topBar = new MDCTopAppBar(element)
  }
}
