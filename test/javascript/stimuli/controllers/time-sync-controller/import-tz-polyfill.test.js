// stimuli/controllers/time-sync-controller/import-tz-polyfill.js
import {
          format,
          importTZPolyfill,
          jestMock,
          originalIDTF,
          setMockStatus,
          supportedIntl,
          unsupportedIntl
                            } from "./_constants.import-tz-polyfill"

jest.mock("date-time-format-timezone", () => "MOCKED")

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TimeSyncController", () => {
      describe("helpers", () => {
        describe("importTZPolyfill", () => {
          beforeAll(() => {
            Object.defineProperty(Intl, "DateTimeFormat", {
              value: jestMock,
              configurable: true,
              writable: true
            })
          })

          afterAll(() => {
            Object.defineProperty(Intl, "DateTimeFormat", {
              value: originalIDTF,
              configurable: true,
              writable: true
            })
          })

          describe("[tzPolyfillImport]", () => {
            it("is empty by default", () => {
              expect(importTZPolyfill.tzPolyfillImport).toBe(undefined)
            })

            it("is settable", () => {
              importTZPolyfill.tzPolyfillImport = importTZPolyfill

              expect(importTZPolyfill.tzPolyfillImport).toBe(importTZPolyfill)

              importTZPolyfill.tzPolyfillImport = undefined
            })

            it("is set to the resulting promise of calling importTZPolyfill", async () => {
              await importTZPolyfill()

              expect(importTZPolyfill.tzPolyfillImport).toBeInstanceOf(Promise)
            })

            it("importTZPolyfill awaits it if truthy", async () => {
              importTZPolyfill.tzPolyfillImport = Promise.resolve("TEST SUCCESS")
              let result = importTZPolyfill()

              expect(result).toBe(importTZPolyfill.tzPolyfillImport)
              expect(await result).toBe("TEST SUCCESS")

              importTZPolyfill.tzPolyfillImport = true
              result = importTZPolyfill()

              expect(result).toBe(true)

              importTZPolyfill.tzPolyfillImport = false
              result = importTZPolyfill()

              expect(result).toBeInstanceOf(Promise)
              expect(await result).toEqual({})
            })
          })

          describe("Intl.DateTimeFormat", () => {
            beforeEach(() => {
              importTZPolyfill.tzPolyfillImport = null
              jestMock.mockClear()
              format.mockClear()
              console.error = jest.fn()
            })

            describe("browser supported", () => {
              beforeEach(() => {
                setMockStatus(supportedIntl)
              })

              it("returns an empty object", async () => {
                const result = await importTZPolyfill()
                expect(result).toEqual({})

                for (let i = 0; i < 10; i++) {
                  expect(jestMock).toHaveBeenCalledTimes(1)

                  expect(jestMock).toHaveBeenLastCalledWith(
                    'en',
                    {
                      timeZone: 'America/Los_Angeles',
                      timeZoneName: 'long'
                    }
                  )

                  expect(format).toHaveBeenCalledTimes(1)
                  expect(format).toHaveBeenLastCalledWith()

                  expect(console.error).not.toHaveBeenCalled()

                  expect(await importTZPolyfill()).toBe(result)
                }
              })
            })

            describe("browser unsupported", () => {
              beforeEach(() => {
                setMockStatus(unsupportedIntl)
              })

              it("returns the date-time-format-timezone polyfill module", async () => {

                const result = await importTZPolyfill()
                expect(result).toEqual({ default: "MOCKED" })

                for (let i = 0; i < 10; i++) {
                  expect(jestMock).toHaveBeenCalledTimes(1)
                  expect(jestMock).toHaveBeenLastCalledWith(
                    'en',
                    {
                      timeZone: 'America/Los_Angeles',
                      timeZoneName: 'long'
                    }
                  )

                  expect(format).not.toHaveBeenCalled()

                  expect(console.error).toHaveBeenCalledTimes(1)
                  expect(console.error).toHaveBeenLastCalledWith(new Error("Not Supported Mock"))

                  expect(await importTZPolyfill()).toBe(result)
                }
              })
            })
          })
        })
      })
    })
  })
})
