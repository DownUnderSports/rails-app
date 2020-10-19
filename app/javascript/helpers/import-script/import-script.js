function loadError(oError) {
  throw new URIError("The script " + oError.target.src + " didn't load correctly.");
}

function createScriptLoader(location) {
  return new Promise((resolve, reject) => {
    const tag = document.createElement("SCRIPT")
    tag.onerror = reject
    tag.onload = resolve
    document.head.appendChild(tag)
    tag.src = location
  })
}

export const scriptSubscriptions = {}
export async function importScript(location) {
  try {
    if(scriptSubscriptions[location]) return await scriptSubscriptions[location]
    else {
      scriptSubscriptions[location] = createScriptLoader(location)
      return await importScript(location)
    }
  } catch(err) {
    console.error(err)
    throw err
  }
}
