export { importTZPolyfill } from "stimuli/controllers/time-sync-controller/import-tz-polyfill"


let mockStatus

const originalIDTF = Intl.DateTimeFormat,
      jestMock = jest.fn().mockImplementation((...args) => mockStatus ? mockStatus(...args) : originalIDTF(...args)),
      format = jest.fn(),
      supportedIntl = () => ({ format }),
      unsupportedIntl = () => { throw new Error("Not Supported Mock") },
      setMockStatus = v => mockStatus = v


export {
  format,
  jestMock,
  originalIDTF,
  setMockStatus,
  supportedIntl,
  unsupportedIntl,
}
