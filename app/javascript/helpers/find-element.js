export function findElement(root, selector) {
  if (typeof root == "string") {
    selector = root
    root = document
  }
  return root.querySelector(selector)
}
