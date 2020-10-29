export class DataMap {
  constructor(scope) {
    this.scope = scope
  }

  get element() {
    return this.scope.element
  }

  get identifier() {
    return this.scope.identifier
  }

  get = (key) => {
    const formattedKey = this.getFormattedKey(key)
    return this.element.getAttribute(formattedKey)
  }

  set = (key, value) => {
    const formattedKey = this.getFormattedKey(key)
    this.element.setAttribute(formattedKey, value)
    return this.get(key)
  }

  has = (key) => {
    const formattedKey = this.getFormattedKey(key)
    return this.element.hasAttribute(formattedKey)
  }

  delete = (key) => {
    if (this.has(key)) {
      const formattedKey = this.getFormattedKey(key)
      this.element.removeAttribute(formattedKey)
      return true
    } else {
      return false
    }
  }

  getFormattedKey(key) {
    return `data-${this.identifier}-${dasherize(key)}`
  }
}

function dasherize(value) {
  return value.replace(/([A-Z])/g, (_, char) => `-${char.toLowerCase()}`)
}
