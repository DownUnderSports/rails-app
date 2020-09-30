import { Controller } from "stimuli"
import { MDCDrawer } from '@material/drawer';

export class AppDrawerController extends Controller {
  static keyName = "app-drawer"
  static targets = [ "drawer", "logo", "link" ]

  connect() {
    this.appDrawer = this.drawerTarget
    this.isOpen = this.isOpen
  }

  disconnect() {
    this.appDrawer.destroy()
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

AppDrawerController.registerController()
