import { Controller } from "stimulus"

export class ClipboardController extends Controller {
  static targets = [ "source" ]
  connect() {
    if(document.queryCommandSupported("copy")) {
      this.element.classList.add("clipboard--supported")
    }
  }

  disconnect() {
    this.element.classList.remove('clipboard--supported')
  }

  copy(ev) {
    ev.preventDefault()
    this.sourceTarget.select()
    document.execCommand("copy")
  }
}
