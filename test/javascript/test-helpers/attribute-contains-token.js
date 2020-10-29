export function attributeContainsToken(attributeName, token) {
  return `[${attributeName}~="${token}"]`
}

export default attributeContainsToken
