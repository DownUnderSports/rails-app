let tzPolyfillImport

export async function importTZPolyfill() {
  try {
    if(tzPolyfillImport) return await tzPolyfillImport
    else {
      try {
        new Intl.DateTimeFormat('en', {
            timeZone: 'America/Los_Angeles',
            timeZoneName: 'long'
        }).format();
        tzPolyfillImport = Promise.resolve()
      } catch(err) {
        console.error(err)
        tzPolyfillImport = import("date-time-format-timezone")
        return await tzPolyfillImport
      }
    }
  } catch(err) {
    console.error(err)
    throw err
  }
}
