let tzPolyfillImport

export function importTZPolyfill() {
  try {
    if(tzPolyfillImport) return tzPolyfillImport
    else {
      try {
        new Intl.DateTimeFormat('en', {
            timeZone: 'America/Los_Angeles',
            timeZoneName: 'long'
        }).format();

        tzPolyfillImport = Promise.resolve({})

        return tzPolyfillImport
      } catch(err) {
        console.error(err)

        tzPolyfillImport = import("date-time-format-timezone")

        return tzPolyfillImport
      }
    }
  } catch(err) {
    console.error(err)
    throw err
  }
}

Object.defineProperty(importTZPolyfill, "tzPolyfillImport", {
  get: () => tzPolyfillImport,
  set: v => tzPolyfillImport = v,
  configurable: false
})
