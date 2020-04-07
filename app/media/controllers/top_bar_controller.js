import { Controller } from "stimulus"
import { MDCTopAppBar } from '@material/top-app-bar';

export class TopBarController extends Controller {
  static targets = [ "nav-button", "title" ]
  connect() {
    this.topBar = this.element
  }

  get topBar() {
    return this._topBar || (this.topBar = this.element)
  }

  set topBar(element) {
    this._topBar = new MDCTopAppBar(element)
  }
}
