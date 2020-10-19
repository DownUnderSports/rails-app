// stimuli/controllers/top-bar-controller/top-bar-controller.test.js
import { MDCTopAppBar } from '@material/top-app-bar';
import { TopBarController } from "stimuli/controllers/top-bar-controller"
import { sleepAsync } from "test-helpers/sleep-async"

const getElements = () => {
  const wrapper = document.getElementById("test-top-bar"),
        title = wrapper.querySelector(".mdc-top-app-bar__title"),
        icon = wrapper.querySelector("#drawer-toggle-button")

  return { wrapper, title, icon }
}


describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("TopBarController", () => {
      beforeEach(() => {
        document.body.innerHTML = `
          <section>
            <header
              id="test-top-bar"
              class="mdc-top-app-bar mdc-top-app-bar--fixed"
              data-controller="top-bar"
            >
              <div class="mdc-top-app-bar__row">
                <section class="mdc-top-app-bar__section mdc-top-app-bar__section--align-start h-100 flex-grow">
                </section>
                <section class="mdc-top-app-bar__section mdc-top-app-bar__section--align-end">
                  <span class="mdc-top-app-bar__title" data-target="top-bar.title">
                    Title
                  </span>
                  <button
                    id="drawer-toggle-button"
                    class="material-icons mdc-top-app-bar__navigation-icon mdc-icon-button edge-even"
                    data-target="top-bar.nav-button"
                    data-action="app-drawer#toggle"
                  >
                    menu
                  </button>
                </section>
              </div>
            </header>
          </section>
        `
        TopBarController.registerController()
      })

      it("has keyName 'top-bar'", () => {
        expect(TopBarController.keyName).toEqual("top-bar")
      })

      it("has targets for nav-button and title", () => {
        expect(TopBarController.targets)
          .toEqual([ "nav-button", "title" ])
      })

      describe("on connect", () => {
        it("sets [top-bar] to be the controller instance", () => {
          const { wrapper } = getElements()

          expect(wrapper["top-bar"])
            .toBeInstanceOf(TopBarController)
        })

        it("sets .topBar to an MDCTopAppBar of element", () => {
          const { wrapper, icon } = getElements(),
                controller = wrapper["top-bar"]

          expect(controller.topBar).toBeInstanceOf(MDCTopAppBar)
          expect(controller.topBar.root_).toBe(wrapper)
          expect(controller.topBar.navIcon_).toBe(icon)
          expect(controller.topBar.scrollTarget_).toBe(window)
        })
      })

      describe("on disconnect", () => {
        const withDisconnect = (cb, opts) => {
          let { setup, teardown } = opts || {}
          return async () => {
            const { wrapper } = getElements()
            try {
              setup = (setup && await setup(wrapper))
              delete wrapper.dataset.controller
              await sleepAsync()
              cb = await cb(wrapper, setup)
              teardown && await teardown(wrapper, setup, cb)
            } finally {
              wrapper.dataset.controller = "top-bar"
              await sleepAsync()
            }
          }
        }

        it("removes [top-bar] from the element",
          withDisconnect(wrapper => {
            expect(wrapper["top-bar"]).toBe(undefined)
          })
        )

        it("calls #destroy on .topBar",
          withDisconnect(
            (_, { mock }) => {
              expect(mock).toHaveBeenCalledTimes(1)
              expect(mock).toHaveBeenLastCalledWith()
            },
            {
              setup: wrapper => {
                const topBar = wrapper["top-bar"].topBar,
                      destroy = topBar.destroy,
                      mock = jest.fn()
                        .mockImplementation(destroy)
                        .mockName("destroy")

                Object.defineProperty(topBar, "destroy", {
                  value: mock,
                  configurable: true
                })

                return { mock, topBar }
              },
              teardown: (_, { topBar }) => {
                if(topBar.hasOwnProperty("destroy")) delete topBar.destroy
              }
            }
          )
        )
      })
    })
  })
})
