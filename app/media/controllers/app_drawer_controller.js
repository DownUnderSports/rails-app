import { Controller } from "stimulus"
import { MDCDrawer } from '@material/drawer';

const isFocusedClass = 'mdc-ripple-upgraded--background-focused'

export class AppDrawerController extends Controller {
  static targets = [ "drawer", "logo", "link" ]

  connect() {
    this.appDrawer = this.drawerTarget
  }

  close(ev) {
    this.appDrawer.open = false
  }

  open(ev) {
    this.appDrawer.open = true
    // setTimeout(() => this.focus(this.linkTarget), 500)
  }

  toggle(ev) {
    this.appDrawer.open
      ? this.close(ev)
      : this.open(ev)
  }

  get appDrawer() {
    return this._appDrawer || (this.appDrawer = this.drawerTarget)
  }

  set appDrawer(element) {
    this._appDrawer = new MDCDrawer(element)
  }

  // focus(target) {
  //   this.focusedLink = target
  //   target.focus()
  //   target.classList.add(isFocusedClass)
  // }
  //
  // moveFocus(ev) {
  //   if(this.isMoveUpEvent(ev)) this.previousLink(ev)
  //   else if(this.isMoveDownEvent(ev)) this.nextLink(ev)
  // }
  //
  // previousLink(ev) {
  //   return false
  //   ev.preventDefault()
  //   const idx = this.focusedLinkIndex - 1
  //   if(idx < 0) {
  //     this.focus(this.linkTargets[this.linkTargets.length - 1])
  //   } else {
  //     this.focus(this.linkTargets[idx])
  //   }
  // }
  //
  // nextLink(ev) {
  //   return false
  //   ev.preventDefault()
  //   const idx = this.focusedLinkIndex + 1
  //   if(idx >= this.linkTargets.length) {
  //     this.focus(this.linkTarget)
  //   } else {
  //     this.focus(this.linkTargets[idx])
  //   }
  // }
  //
  // isMoveDownEvent(ev) {
  //   return (ev.key === "ArrowDown")
  //     || (ev.key === "ArrowRight")
  //     || (ev.which === 40)
  //     || (ev.keyCode === 40)
  //     || (ev.which === 39)
  //     || (ev.keyCode === 39)
  // }
  //
  // isMoveUpEvent(ev) {
  //   return (ev.key === "ArrowUp")
  //     || (ev.key === "ArrowLeft")
  //     || (ev.which === 38)
  //     || (ev.keyCode === 38)
  //     || (ev.which === 37)
  //     || (ev.keyCode === 37)
  // }
  //
  // removeFocus() {
  //   this.focusedLink.classList.remove(isFocusedClass)
  // }

  // get focusedLinkIndex() {
  //   return this.linkTargets.indexOf(this.focusedLink)
  // }
  //
  // get focusedLink() {
  //   return this._focusedLink
  // }
  //
  // set focusedLink(el) {
  //   if(this.focusedLink) this.removeFocus()
  //   this._focusedLink = el
  // }
}
