import { attributeContainsToken } from "test-helpers/attribute-contains-token"

export class TargetSet {
  constructor(scope) {
    this.scope = scope
  }

  get element() {
    return this.scope.element
  }

  get identifier() {
    return this.scope.identifier
  }

  get schema() {
    return this.scope.schema
  }

  has = (targetName) => this.find(targetName) != null

  find = (...targetNames) => {
    const selector = this.getSelectorForTargetNames(targetNames)
    return this.scope.findElement(selector)
  }

  findAll = (...targetNames) => {
    const selector = this.getSelectorForTargetNames(targetNames)
    return this.scope.findAllElements(selector)
  }

  getSelectorForTargetNames = (targetNames) =>
    targetNames
      .map(targetName => this.getSelectorForTargetName(targetName))
      .join(", ")

  getSelectorForTargetName = (targetName) =>
    attributeContainsToken(this.schema.targetAttribute, `${this.identifier}.${targetName}`)
}
