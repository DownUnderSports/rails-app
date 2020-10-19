const genChar = (size) =>
  Math.random().toString(16).slice(-size)

const genId = () =>
  Date.now().toString(36)
  + '-' + genChar(4)
  + '-' + genChar(4)
  + '-' + genChar(4)
  + '-' + genChar(12)


export function uniqueId() {
  let id
  while(!id || document.getElementById(id)) id = genId()
  return id
}
