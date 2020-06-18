import { Controller } from "stimuli"

export class LinkListController extends Controller {
  static keyName = "link-list"

  follow = (ev) => {
    ev.preventDefault()

    const link = this.getLinkFromTarget(ev.currentTarget)
    if("replace" in ev.target.dataset) {
      const repl = ev.target.dataset.replace.split("|")
      link.href = link.replace(repl[0], repl[1])
    }

    link.click()
  }

  getLinkFromTarget(target) {
    let link = [
      target,
      ...target.querySelectorAll("a[href]")
    ].filter(el => el && el.matches('a'))[0]
    link = (link && link.href) || "#"
    const el = document.createElement('a')
    el.href   = link
    el.target = link.target
    el.rel    = link.rel

    return el
  }
}

LinkListController.registerController()
