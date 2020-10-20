// stimuli/controllers/list-controller/list-controller.test.js
import { MDCList } from "@material/list";
import { MDCRipple } from '@material/ripple';
import { ListController } from "stimuli/controllers/list-controller"
import { sleepAsync } from "test-helpers/sleep-async"
import { removeControllers } from "test-helpers/remove-controllers"

const getElements = () => {
  const wrapper = document.getElementById("test-list"),
        items = wrapper.querySelectorAll(".mdc-list-item")

  return { wrapper, items }
}

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("ListController", () => {
      beforeEach(() => {
        document.body.innerHTML = `
          <ul id="test-list" class="mdc-list mdc-list--two-line" data-controller="list" data-target="list.list">
            <li class="mdc-list-item" tabindex="0" data-target="list.item">
              <span class="mdc-list-item__text">
                <span class="mdc-list-item__primary-text">Item One</span>
                <span class="mdc-list-item__secondary-text">Line Two</span>
              </span>
            </li>
            <li class="mdc-list-item" data-target="list.item">
              <span class="mdc-list-item__text">
                <span class="mdc-list-item__primary-text">Item Two</span>
                <span class="mdc-list-item__secondary-text">Line Two</span>
              </span>
            </li>
            <li class="mdc-list-item" data-target="list.item">
              <span class="mdc-list-item__text">Item Three</span>
            </li>
          </ul>
        `
        ListController.registerController()
      })
      afterEach(removeControllers)

      it("has keyName 'list'", () => {
        expect(ListController.keyName).toEqual("list")
      })

      it("has targets for list and item(s)", () => {
        expect(ListController.targets)
          .toEqual([ "list", "item" ])
      })

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
          expect([...controller.list.listElements]).toEqual([...items])
        })
      })

      describe("on disconnect", () => {
        it("removes [list] from the element", async () => {
          const { wrapper } = getElements()
          expect(wrapper["controllers"]["list"]).toBeInstanceOf(ListController)
          await wrapper["controllers"]["list"].disconnect()
          expect(wrapper["controllers"]["list"]).toBe(undefined)
        })

        // it("calls #destroy on .list",
        //   withDisconnect(
        //     async (_, { mock }) => {
        //       expect(mock).toHaveBeenCalledTimes(1)
        //       expect(mock).toHaveBeenLastCalledWith()
        //     },
        //     {
        //       setup: async wrapper => {
        //         const list = wrapper["controllers"]["list"].list,
        //               destroy = list.destroy,
        //               mock = jest.fn()
        //                 .mockImplementation(destroy)
        //                 .mockName("destroy")
        //
        //         Object.defineProperty(list, "destroy", {
        //           value: mock,
        //           configurable: true
        //         })
        //
        //         return { mock, list }
        //       },
        //       teardown: async (_, { list }) => {
        //         if(list.hasOwnProperty("destroy")) delete list.destroy
        //       }
        //     }
        //   )
        // )
      })

      describe("[ripples]", () => {
        test.todo("write tests for [ripples]")
      })

      describe(".list", () => {
        it("is an MDCList of element", () => {
          const { wrapper, input } = getElements(),
                controller = wrapper["controllers"]["list"]

          expect(controller.list).toBeInstanceOf(MDCList)
          expect(controller.list.root_).toBe(wrapper)
          expect(controller.list.input_).toBe(input)
        })

        it("returns [_list]", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["list"],
                tf = controller._list
          try {
            expect(controller.list).toBe(controller._list)

            controller._list = "asdf"

            expect(controller.list).toEqual("asdf")
          } finally {
            controller._list = tf
          }
        })
      })

      describe(".list=", () => {
        it("sets [list] to an MDCList", () => {
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["list"],
                div = document.createElement("DIV")

          div.innerHTML = `
            <input id="test-email" data-target="list.input" class="mdc-list__input" />
          `

          expect(() => { controller.list = div })
            .not.toThrow("List Missing Input")
        })
      })
    })
  })
})
