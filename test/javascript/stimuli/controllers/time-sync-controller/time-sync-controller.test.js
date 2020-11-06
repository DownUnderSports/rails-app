// stimuli/controllers/time-sync-controller/time-sync-controller.js
import { MDCTextField } from "@material/textfield";
import { TimeSyncController } from "stimuli/controllers/time-sync-controller"
import {
          createTemplateController,
          getElements,
          mockScope,
          registerController,
          template,
          unregisterController
                                      } from "./_constants.time-sync-controller"

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TimeSyncController", () => {

      it("has keyName 'time-sync'", () => {
        expect(TimeSyncController.keyName).toEqual("time-sync")
      })

      it("has targets for date", () => {
        expect(TimeSyncController.targets)
          .toEqual([ "date" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          test.todo("on connect")
          it("sets [time-sync] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["time-sync"])
              .toBeInstanceOf(TimeSyncController)
          })
        })

        describe("on disconnect", () => {
          test.todo("on disconnect")
          it("removes [time-sync] from the element", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["time-sync"]

            expect(wrapper["controllers"]["time-sync"]).toBeInstanceOf(TimeSyncController)

            await controller.disconnect()

            expect(wrapper["controllers"]["time-sync"]).toBe(undefined)

            await controller.connect()
          })
        })
      })

      describe("getters/setters", () => {})

      describe("actions", () => {
        test.todo(".setValues")
      })
    })
  })
})
