// stimuli/constants/controller.js
import { Application } from "stimuli/constants/application"
import { Controller } from "stimuli/constants/controller"
import { Scope } from "test-helpers/mocks/stimulus/scope"

jest.mock("stimuli/constants/application", () => ({ Application: { register: jest.fn(), unload: jest.fn() } }))

const testKeys = []
for(let i = 0; i < 10; i++) testKeys.push(`test-key-${Math.random()}`.replace(/\./g, ""))

describe("Stimuli", () => {
  describe("Constants", () => {
    describe("Controller", () => {
      test.todo("write tests for stimuli/constants/controller.js")

      describe("static", () => {
        describe(".load", () => {
          it("calls Application.register with the given key and [this]", () => {
            let i = 0

            while(i < testKeys.length) {
              const k = testKeys[i]
              expect(() => Controller.load(k)).not.toThrow()
              expect(Application.register).toHaveBeenCalledTimes(++i)
              expect(Application.register).toHaveBeenNthCalledWith(i, k, Controller)
            }

            expect(i).toBe(10)
          })

          it("throws an error if not given a value and [keyName] is not set", () => {
            expect(() => Controller.load()).toThrow(TypeError)
            expect(() => Controller.load()).toThrow(new TypeError("Controller Key Required"))
          })

          it("it uses [keyName] if not given a key", () => {
            let i = 0

            while(i < testKeys.length) {
              const k = testKeys[i]
              try {
                Controller.keyName = k
                expect(() => Controller.load()).not.toThrow()
                expect(Application.register).toHaveBeenCalledTimes(++i)
                expect(Application.register).toHaveBeenNthCalledWith(i, k, Controller)
              } finally {
                Controller.keyName = null
              }
            }

            expect(i).toBe(10)
          })
        })

        describe(".unload", () => {
          it("calls Application.unload with the given key and [this]", () => {
            let i = 0

            while(i < testKeys.length) {
              const k = testKeys[i]
              expect(() => Controller.unload(k)).not.toThrow()
              expect(Application.unload).toHaveBeenCalledTimes(++i)
              expect(Application.unload).toHaveBeenNthCalledWith(i, k)
            }

            expect(i).toBe(10)
          })

          it("throws an error if not given a value and [keyName] is not set", () => {
            expect(() => Controller.unload()).toThrow(TypeError)
            expect(() => Controller.unload()).toThrow(new TypeError("Controller Key Required"))
          })

          it("it uses [keyName] if not given a key", () => {
            let i = 0

            while(i < testKeys.length) {
              const k = testKeys[i]
              try {
                Controller.keyName = k
                expect(() => Controller.unload()).not.toThrow()
                expect(Application.unload).toHaveBeenCalledTimes(++i)
                expect(Application.unload).toHaveBeenNthCalledWith(i, k)
              } finally {
                Controller.keyName = null
              }
            }

            expect(i).toBe(10)
          })
        })

        describe("[keyName]", () => {
          it("is scoped to the current class", () => {
            class InheritedController extends Controller {}

            Controller.keyName = "test-key"

            expect(Controller.keyName).toBe("test-key")
            expect(InheritedController.keyName).toBe(undefined)

            InheritedController.keyName = "test-scope"

            expect(InheritedController.keyName).toBe("test-scope")
            expect(Controller.keyName).toBe("test-key")

            Controller.keyName = null

            expect(Controller.keyName).toBe(null)
            expect(InheritedController.keyName).toBe("test-scope")

            InheritedController.keyName = false

            expect(InheritedController.keyName).toBe(false)
            expect(Controller.keyName).toBe(null)

            class DeepInheritedController extends InheritedController {}

            expect(DeepInheritedController.keyName).toBe(undefined)
            expect(InheritedController.keyName).toBe(false)
            expect(Controller.keyName).toBe(null)

            DeepInheritedController.keyName = "deep-scope"
            InheritedController.keyName = "test-scope"
            Controller.keyName = "test-key"

            expect(DeepInheritedController.keyName).toBe("deep-scope")
            expect(InheritedController.keyName).toBe("test-scope")
            expect(Controller.keyName).toBe("test-key")
          })
        })
      })

      describe("actions", () => {
        describe(".nextDisconnect", () => {
          test.todo(".nextDisconnect")
        })

        describe(".connect", () => {
          const createController = (starting) => {
            const controller = new Controller(),
                  element = document.createElement("DIV"),
                  scope = new Scope("test-key", element)

            let scoped

            Object.defineProperty(controller, "scope", {
              get: () => scoped,
              set: v => v ? (scoped = scope) : scoped = undefined,
              configurable: true
            })

            controller.scope = starting

            return controller
          }

          describe("[scope] is not set", () => {
            it("throws a TypeError", async () => {
              const controller = createController()

              await expect(controller.connect())
                      .rejects
                      .toThrow(TypeError)

              await expect(controller.connect())
                      .rejects
                      .toThrow(new TypeError("Cannot read property 'element' of undefined"))
            })
          })

          describe("[scope] is set", () => {
            it("sets [_isConnected] to true", async () => {
              const controller = createController(true)

              expect(controller._isConnected).toBe(undefined)

              await controller.connect()

              expect(controller._isConnected).toBe(true)
            })

            it("sets [elements][controllers][[this][identifier]] to [this]", async () => {
              const controller = createController(true)

              expect(controller.element["controllers"]).toBe(undefined)

              await controller.connect()

              expect(controller.element["controllers"]).toEqual({ ["test-key"]: controller })
              expect(controller.element["controllers"]["test-key"]).toBe(controller)
            })

            it("runs .connected if exists", async () => {
              const controller = createController(true),
                    mockConnected = jest.fn()
                                        .mockImplementationOnce(() => false)
                                        .mockImplementationOnce(() => true)
                                        .mockImplementationOnce(() => () => {})
                                        .mockImplementationOnce(() => true)
                                        .mockImplementationOnce(() => () => { throw new Error("Bad Mock") })

              Object.defineProperty(controller, "connected", {
                get: mockConnected,
                configurable: true
              })

              await controller.connect()

              expect(mockConnected).toHaveBeenCalledTimes(1)

              await controller.connect()

              expect(mockConnected).toHaveBeenCalledTimes(3)

              await expect(controller.connect())
                      .rejects
                      .toThrow(new Error("Bad Mock"))

              expect(mockConnected).toHaveBeenCalledTimes(5)
            })
          })
        })

        describe(".disconnect", () => {
          const createController = (starting) => {
            const controller = new Controller(),
                  element = document.createElement("DIV"),
                  scope = new Scope("test-key", element)

            let scoped

            Object.defineProperty(controller, "scope", {
              get: () => scoped,
              set: v => v ? (scoped = scope) : scoped = undefined,
              configurable: true
            })

            controller.scope = starting

            return controller
          }

          describe("[scope] is not set", () => {
            it("ignores the issue", async () => {
              const controller = createController()


              await expect(controller.disconnect())
                      .resolves
                      .toBe(undefined)
            })
          })

          describe("[scope] is set", () => {
            it("sets [_isConnected] to false", async () => {
              const controller = createController(true)

              expect(controller._isConnected).toBe(undefined)

              await controller.disconnect()

              expect(controller._isConnected).toBe(false)
            })

            it("removes [elements][controllers][[this][identifier]] if exists", async () => {
              const controller = createController(true)

              expect(controller.element["controllers"]).toBe(undefined)

              await expect(controller.disconnect()).resolves.toBe(undefined)

              expect(controller.element["controllers"]).toBe(undefined)

              const controllers = { ["test-key"]: true, unrelatedKey: true }

              controller.element["controllers"] = controllers

              await expect(controller.disconnect()).resolves.toBe(undefined)

              expect(controller.element["controllers"]).toBe(controllers)
              expect(controllers).toEqual({ unrelatedKey: true})
              expect(controllers["test-key"]).toBe(undefined)
            })

            it("runs .disconnected if exists", async () => {
              const controller = createController(true),
                    error = new Error("Bad Mock"),
                    mockConnected = jest.fn()
                                        .mockImplementationOnce(() => false)
                                        .mockImplementationOnce(() => true)
                                        .mockImplementationOnce(() => () => {})
                                        .mockImplementationOnce(() => true)
                                        .mockImplementationOnce(() => () => { throw error })

              console.error = jest.fn()

              Object.defineProperty(controller, "disconnected", {
                get: mockConnected,
                configurable: true
              })

              await controller.disconnect()

              expect(mockConnected).toHaveBeenCalledTimes(1)

              await controller.disconnect()

              expect(mockConnected).toHaveBeenCalledTimes(3)

              expect(console.error).not.toHaveBeenCalled()

              await expect(controller.disconnect()).resolves.toBe(undefined)

              expect(console.error).toHaveBeenCalledTimes(1)
              expect(console.error.mock.calls[0][0]).toBe(error)

              expect(mockConnected).toHaveBeenCalledTimes(5)
            })


            it("runs resolves all [disconnectPromises]", async () => {
              const controller = createController(true)

              const promises = []
              let i = 0
              while(i++ < 10) promises.push(controller.nextDisconnect())

              for(const promise of promises) expect(promise).toBeInstanceOf(Promise)

              expect(Promise.all(promises)).resolves.toEqual(promises.map(() => void 0))
              const result = expect(Promise.all(promises)).resolves.toEqual(promises.map(() => void 0))

              await expect(controller.disconnect()).resolves.toBe(undefined)

              await result
            })
          })
        })
      })

      describe("getters/setters", () => {
        describe("[disconnectPromises]", () => {
          it("defaults to an empty array", () => {
            expect((new Controller()).disconnectPromises).toEqual([])
          })

          it("does not have a setter", () => {
            const controller = new Controller(),
                  callFunc = () => controller.disconnectPromises = true

            expect(callFunc).toThrow(TypeError)
            expect(callFunc).toThrow(new TypeError("Cannot set property disconnectPromises of #<Controller> which has only a getter"))
          })
        })
      })
    })
  })
})
