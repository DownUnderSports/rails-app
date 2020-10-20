import { sleepAsync } from "./sleep-async"

export const removeControllers = async () => {
  document
    .querySelectorAll('*')
    .forEach(function(node) {
      try {
        delete node.dataset.controller
      } catch(_) {}
    });

  await sleepAsync()
}

export default removeControllers
