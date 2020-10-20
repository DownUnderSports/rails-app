import { Controller } from "stimuli/constants/controller"

export class ClipboardController extends Controller {
  static keyName = "clipboard"
  static targets = [ "source" ]
  async connected() {
    if(document.queryCommandSupported("copy")) {
      this.element.classList.add("clipboard--supported")
    }
  }

  async disconnected() {
    this.element.classList.remove('clipboard--supported')
  }

  copy(ev) {
    ev.preventDefault()
    this.sourceTarget.select()
    document.execCommand("copy")
  }
}
