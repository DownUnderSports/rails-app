// stimuli/controllers/list-controller/list-controller.test.js
import { MDCList } from "@material/list";
import { MDCRipple } from '@material/ripple';
import { ListController } from "stimuli/controllers/list-controller"
import { removeControllers } from "test-helpers/remove-controllers"
import {
          getElements,
          registerController,
          unregisterController
                                } from "./constants"


describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("ListController", () => {
      it("has keyName 'list'", () => {
        expect(ListController.keyName).toEqual("list")
      })

      it("has targets for list and item(s)", () => {
        expect(ListController.targets)
          .toEqual([ "list", "item" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [list] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["list"])
              .toBeInstanceOf(ListController)
          })

          it("sets .list to an MDCList of element", () => {
            const { wrapper, items } = getElements(),
                  controller = wrapper["controllers"]["list"]

            expect(controller.list).toBeInstanceOf(MDCList)
            expect(controller.list.root_).toBe(wrapper)
            expect(controller.list.listElements).toEqual([...items])
          })
        })

        describe("on disconnect", () => {
          it("removes [list] from the element", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["list"]

            expect(wrapper["controllers"]["list"]).toBeInstanceOf(ListController)

            await controller.disconnect()

            expect(wrapper["controllers"]["list"]).toBe(undefined)

            await controller.connect()
          })

          it("calls #destroy on .list", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["list"],
                  list = controller.list,
                  destroy = list.destroy,
                  mock = jest.fn()
                    .mockImplementation(destroy)
                    .mockName("destroy")

            Object.defineProperty(list, "destroy", {
              value: mock,
              configurable: true
            })

            await controller.disconnect()

            expect(mock).toHaveBeenCalledTimes(1)
            expect(mock).toHaveBeenLastCalledWith()

            if(list.hasOwnProperty("destroy")) delete list.destroy

            await controller.connect()
          })
        })
      })

      describe("getters/setters", () => {
        describe("[ripples]", () => {
          it("defaults to an empty array", () => {
            const controller = new ListController()

            expect(controller.ripples).toEqual([])
          })
        })

        describe("[list]", () => {
          it("does not have a default value", () => {
            const controller = new ListController()

            expect(controller.list).toBe(undefined)
          })

          it("creates an MDCList of the given element", () => {
            const controller = new ListController(),
                  ul = document.createElement("UL")

            expect(() => controller.list = null).toThrow(TypeError)
            expect(() => controller.list = null).toThrow(new TypeError("Cannot read property 'addEventListener' of null"))

            controller.list = ul

            expect(controller.list).toBeInstanceOf(MDCList)
            expect(controller.list.root_).toBe(ul)
            expect(controller.list.listElements).toEqual([])
            expect(controller.list.foundation_.isSingleSelectionList_).toBe(true)
          })

          it("calls .createRipple for each .mdc-list-item element under given element", () => {
            const controller = new ListController(),
                  ul = document.createElement("UL"),
                  li = document.createElement("LI"),
                  liTwo = document.createElement("LI"),
                  liThree = document.createElement("LI")

            li.classList.add("mdc-list-item")
            ul.appendChild(li)

            liTwo.classList.add("mdc-list-item")
            ul.appendChild(liTwo)

            ul.appendChild(liThree)

            Object.defineProperty(controller, "createRipple", {
              value: jest.fn(),
              configurable: true
            })

            controller.list = ul

            expect(controller.createRipple).toHaveBeenCalledTimes(2)
            expect(controller.createRipple).toHaveBeenNthCalledWith(1, li, 0, controller.list.listElements)
            expect(controller.createRipple).toHaveBeenNthCalledWith(2, liTwo, 1, controller.list.listElements)
            expect(controller.createRipple).toHaveBeenLastCalledWith(liTwo, 1, controller.list.listElements)
            expect(controller.createRipple).toHaveBeenCalledWith(liTwo, 1, controller.list.listElements)
            expect(controller.createRipple).not.toHaveBeenCalledWith(liThree, expect.anything(), expect.anything())
          })

          it("calls .disconnected if [_list]", () => {
            const controller = new ListController(),
                  ul = document.createElement("UL"),
                  ulTwo = document.createElement("UL"),
                  li = document.createElement("LI"),
                  ogDisconnect = controller.disconnected

            li.classList.add("mdc-list-item")
            ul.appendChild(li)

            Object.defineProperty(controller, "disconnected", {
              value: jest.fn().mockImplementation(ogDisconnect),
              configurable: true
            })

            controller.list = ul

            expect(controller.list).toBeInstanceOf(MDCList)
            expect(controller.list.root_).toBe(ul)
            expect(controller.list.listElements).toEqual([ li ])

            const list = controller.list,
                  ripples = [ ...controller.ripples ]

            controller.list = ulTwo

            expect(controller.list).toBeInstanceOf(MDCList)
            expect(controller.list.root_).toBe(ulTwo)
            expect(controller.list.listElements).toEqual([])

            expect(controller.disconnected).toHaveBeenCalledTimes(1)
            expect(controller.disconnected).toHaveBeenLastCalledWith(list, ripples)
          })
        })
      })

      describe("actions", () => {
        describe(".createRipple", () => {
          it("creates and returns a new MDCRipple from arg[0]", async () => {
            const controller = new ListController(),
                  li = document.createElement("LI"),
                  result = controller.createRipple(li)

            expect(result).toBeInstanceOf(MDCRipple)
            expect(result.root_).toBe(li)
          })

          it("pushes the new ripple to .ripples", async () => {
            const controller = new ListController(),
                  init = controller.createRipple(document.createElement("LI"))

            expect(controller.ripples.length).toBe(1)
            expect(controller.ripples[0]).toBe(init)

            let lastResult = init

            for(let i = 1; i < 10; i++) {
              const result = controller.createRipple(document.createElement("LI"))

              expect(controller.ripples.length).toBe(i + 1)
              expect(controller.ripples[i]).toBe(result)
              expect(controller.ripples[i]).not.toBe(lastResult)
              lastResult = result
            }
          })
        })

        describe(".destroyRipple", () => {
          it("calls .destroy on the given ripple", async () => {
            const controller = new ListController(),
                  fakeRipple = { destroy: jest.fn() }

            await controller.destroyRipple(fakeRipple)
            expect(fakeRipple.destroy).toHaveBeenCalledTimes(1)
            expect(fakeRipple.destroy).toHaveBeenLastCalledWith()

            await expect(controller.destroyRipple(1))
              .rejects
              .toThrow(new TypeError("ripple.destroy is not a function"))
          })

          it("removes the given ripple from ripples", async () => {
            const controller  = new ListController(),
                  fakeRipple  = { destroy: jest.fn() },
                  otherRipple = { destroy: jest.fn() }

            const ripples = [ fakeRipple, 1, fakeRipple, 2, otherRipple ]
            controller._ripples = ripples

            controller.logAll = true

            await controller.destroyRipple(fakeRipple)

            expect(ripples).toEqual([ 1, 2, otherRipple ])
            expect(fakeRipple.destroy).toHaveBeenCalledTimes(1)
            expect(fakeRipple.destroy).toHaveBeenLastCalledWith()
            expect(otherRipple.destroy).not.toHaveBeenCalled()

            await controller.destroyRipple(otherRipple)

            expect(ripples).toEqual([ 1, 2 ])
            expect(otherRipple.destroy).toHaveBeenCalledTimes(1)
            expect(otherRipple.destroy).toHaveBeenLastCalledWith()

            for (let i = 0; i < ripples.length; i++) {
              await expect(controller.destroyRipple(ripples[i]))
                .rejects
                .toThrow(new TypeError("ripple.destroy is not a function"))

              expect(ripples).toEqual([ 1, 2 ])
            }
          })
        })
      })
    })
  })
})
