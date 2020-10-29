import { sleepAsync } from "./sleep-async"

export const removeControllers = async () => {
  const promises = []
  const nodes = Array.from(document.querySelectorAll('*'))
  for(const node of nodes) {
    try {
      if(node["controllers"]) {
        for(let key in node["controllers"]) {
          promises.push(node["controllers"][key].nextDisconnect())
        }
      }
      delete node.dataset.controller
    } catch(_) {}
  }

  await Promise.all(promises)
  await sleepAsync()
}

export default removeControllers
