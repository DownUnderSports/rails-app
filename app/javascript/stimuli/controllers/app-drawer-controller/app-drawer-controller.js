import { Controller } from "stimuli/constants/controller"
import { MDCDrawer } from '@material/drawer';

export class AppDrawerController extends Controller {
  static keyName = "app-drawer"
  static targets = [ "drawer", "logo", "link" ]

  async connected() {
    this.appDrawer = this.drawerTarget
    this.isOpen = this.isOpen
  }

  async disconnected() {
    this.appDrawer && await this.appDrawer.destroy()
  }

  get isOpen() {
    return this.data.get('open') === "true"
  }

  set isOpen(state) {
    this.data.set('open', String(state))
    this.appDrawer.open = this.isOpen
  }

  close() {
    this.isOpen = false
  }

  open() {
    this.isOpen = true
  }

  toggle(ev) {
    this.isOpen
      ? this.close()
      : this.open()
  }

  get appDrawer() {
    return this._appDrawer
  }

  set appDrawer(element) {
    this._appDrawer = new MDCDrawer(element)
  }
}
