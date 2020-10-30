import { sleepAsync } from "helpers/sleep-async"
import { Schema } from "test-helpers/mocks/stimulus/schema"
import { attributeContainsToken } from "test-helpers/attribute-contains-token"

const removeController = (controller) => {
  return async () => {
    const promises = []
    const nodes = Array.from(document.querySelectorAll(attributeContainsToken(Schema.controllerAttribute, controller.keyName)))

    for(const node of nodes) {
      if(node["controllers"]) {
        for(const key in node["controllers"]) {
          promises.push(node["controllers"][key].nextDisconnect())
        }
      }
      delete node.dataset.controller
    }
    await Promise.all(promises)
    await sleepAsync()
    controller.unload()
    await sleepAsync()
  }
}

const addController = (controller, template) => {
  return async () => {
    document.body.innerHTML = template

    controller.load()
    await sleepAsync()

    const elements = Array.from(document.querySelectorAll(attributeContainsToken(Schema.controllerAttribute, controller.keyName)))

    const promises = []

    for(const element of elements) {
      promises.push(
        new Promise(resolve => {
          let loop
          loop = () => {
            if(element["controllers"] && element["controllers"][controller.keyName]) resolve()
            else setTimeout(loop)
          }
          loop()
        })
      )
    }
    await Promise.all(promises)
    await sleepAsync()
  }
}

export const controllerRegistration = (controller, template) => {
  const registerController   = addController(controller, template),
        unregisterController = removeController(controller)

  return { registerController, unregisterController }
}

export default controllerRegistration
