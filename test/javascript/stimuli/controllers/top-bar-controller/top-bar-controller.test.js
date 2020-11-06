// stimuli/controllers/top-bar-controller/top-bar-controller.js
import { MDCTopAppBar } from '@material/top-app-bar';
import { TopBarController } from "stimuli/controllers/top-bar-controller"
import { sleepAsync } from "helpers/sleep-async"
import {
          getElements,
          registerController,
          template,
          unregisterController
                                } from "./_constants"

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TopBarController", () => {
      it("has keyName 'top-bar'", () => {
        expect(TopBarController.keyName).toEqual("top-bar")
      })

      it("has targets for nav-button and title", () => {
        expect(TopBarController.targets)
          .toEqual([ "nav-button", "title" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [top-bar] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["top-bar"])
              .toBeInstanceOf(TopBarController)
          })

          it("sets .topBar to an MDCTopAppBar of element", () => {
            const { wrapper, icon } = getElements(),
                  controller = wrapper["controllers"]["top-bar"]

            expect(controller.topBar).toBeInstanceOf(MDCTopAppBar)
            expect(controller.topBar.root_).toBe(wrapper)
            expect(controller.topBar.navIcon_).toBe(icon)
            expect(controller.topBar.scrollTarget_).toBe(window)
          })
        })

        describe("on disconnect", () => {
          it("removes [top-bar] from the element", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["top-bar"]
            expect(wrapper["controllers"]["top-bar"]).toBeInstanceOf(TopBarController)

            await controller.disconnect()

            expect(wrapper["controllers"]["top-bar"]).toBe(undefined)

            await controller.connect()
          })

          it("calls #destroy on .topBar", async () => {
            const { wrapper } = getElements(),
                  topBar = wrapper["controllers"]["top-bar"].topBar,
                  destroy = topBar.destroy,
                  mock = jest.fn()
                    .mockImplementation(destroy)
                    .mockName("destroy")

            Object.defineProperty(topBar, "destroy", {
              value: mock,
              configurable: true
            })

            await wrapper["controllers"]["top-bar"].disconnect()

            expect(mock).toHaveBeenCalledTimes(1)
            expect(mock).toHaveBeenLastCalledWith()

            if(topBar.hasOwnProperty("destroy")) delete topBar.destroy
          })
        })
      })

      describe("getters/setters", () => {
        describe("[topBar]", () => {
          it("does not have a default", () => {
            const controller = new TopBarController()

            expect(controller.topBar).toBe(undefined)
          })

          it("creates an MDCTopAppBar of the given element", () => {
            const controller = new TopBarController()

            expect(() => controller.topBar = null).toThrow(TypeError)
            expect(() => controller.topBar = null).toThrow(new TypeError("Cannot read property 'querySelector' of null"))

            expect(() => controller.topBar = document.createElement("div")).not.toThrow()


            expect(controller.topBar).toBeInstanceOf(MDCTopAppBar)
          })
        })
      })
    })
  })
})
