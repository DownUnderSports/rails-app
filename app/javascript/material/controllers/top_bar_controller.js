import { Controller } from "stimuli"
import { MDCTopAppBar } from '@material/top-app-bar';

export class TopBarController extends Controller {
  static keyName = "top-bar"
  static targets = [ "nav-button", "title" ]
  connect() {
    this.topBar = this.element
  }

  disconnect() {
    this.topBar.destroy()
  }

  get topBar() {
    return this._topBar
  }

  set topBar(element) {
    this._topBar = new MDCTopAppBar(element)
  }
}

TopBarController.registerController()
