export function toArray(value) {
  if (Array.isArray(value)) {
    return value
  } else if (Array.from) {
    return Array.from(value)
  } else {
    return [].slice.call(value)
  }
}
