// stimuli/controllers/dynamic-link-controller/dynamic-link-controller.test.js
import { DynamicLinkController } from "stimuli/controllers/dynamic-link-controller"
import { allStandardTags } from "test-helpers/all-standard-tags"
import {
          createTemplateController,
          getElements,
          registerController,
          unregisterController
                                    } from "./constants"


describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("DynamicLinkController", () => {
      it("has keyName 'dynamic-link'", () => {
        expect(DynamicLinkController.keyName).toEqual("dynamic-link")
      })

      it("has no targets", () => {
        expect(DynamicLinkController.targets).toEqual([])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [dynamic-link] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["dynamic-link"])
              .toBeInstanceOf(DynamicLinkController)
          })
        })

        describe("on disconnect", () => {
          it("removes [dynamic-link] from the element", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["dynamic-link"]

            expect(wrapper["controllers"]["dynamic-link"]).toBeInstanceOf(DynamicLinkController)

            await controller.disconnect()

            expect(wrapper["controllers"]["dynamic-link"]).toBe(undefined)

            await controller.connect()
          })
        })
      })

      describe("actions", () => {
        describe(".follow", () => {
          const simEvent = {
            preventDefault: jest.fn(),
            stopPropagation: jest.fn(),
            mockClear: function() {
              this.preventDefault.mockClear()
              this.stopPropagation.mockClear()
              this.currentTarget = null
              this.target = null
            },
            get currentTarget() {
              return this._currentTarget || (this._currentTarget = getElements().wrapper)
            },
            set currentTarget(value) {
              this._currentTarget = value
              return value
            },
            get target() {
              return this._target || this._currentTarget
            },
            set target(value) {
              this._target = value
              return value
            },
          }

          beforeEach(() => {
            simEvent.mockClear()
          })

          it("prevents the default action", () => {
            const controller = new DynamicLinkController()

            controller.follow(simEvent)

            expect(simEvent.preventDefault).toHaveBeenCalledTimes(1)
            expect(simEvent.preventDefault).toHaveBeenLastCalledWith()
          })

          it("calls .getLinkFromTarget with ev[currentTarget]", () => {
            const { wrapper } = getElements(),
                  controller = new DynamicLinkController(),
                  getLinkFromTarget = controller.getLinkFromTarget

            Object.defineProperty(controller, "getLinkFromTarget", {
              value: jest.fn().mockImplementation(getLinkFromTarget)
            })

            controller.follow(simEvent)

            expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(1)
            expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(wrapper)
          })

          it("calls .click on a modified href replaced by [target][data-replace]", () => {
            let link, calledTimes = 0
            const controller = createTemplateController(),
                  {
                    wrapper,
                    firstLink,
                    secondLink,
                    noReplacePhoneIcon,
                    noReplacePhoneSpan,
                    replacePhoneIcon,
                    replacePhoneSpan,
                    replaceAllDiv,
                    nestedWrapper,
                    nestedLink,
                    nestedReplace
                  } = getElements(),
                  links = [],
                  getLinkFromTarget = controller.getLinkFromTarget,
                  click = jest.fn(),
                  noReplace = [
                    firstLink,
                    secondLink,
                    noReplacePhoneIcon,
                    noReplacePhoneSpan,
                  ],
                  replace = [
                    replacePhoneIcon,
                    replacePhoneSpan
                  ],
                  nested = [
                    [ nestedWrapper, false ],
                    [ nestedLink, false ],
                    [ nestedReplace, true ]
                  ]

            Object.defineProperty(controller, "getLinkFromTarget", {
              value: jest.fn().mockImplementation((value) => {
                link = getLinkFromTarget(value)
                links.push(link)
                Object.defineProperty(link, "click", {
                  value: click,
                  configurable: true,
                })
                return link
              })
            })

            for (let i = 0; i < noReplace.length; i++) {
              const target = noReplace[i]

              simEvent.currentTarget = wrapper
              simEvent.target = target

              controller.follow(simEvent)

              expect(link).not.toBe(undefined)
              expect(link).toBe(links[calledTimes])
              expect(link).toBeInstanceOf(HTMLElement)
              expect(link.tagName).toBe("A")
              expect(link.href).toBe(firstLink.href)

              expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(++calledTimes)
              expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(wrapper)
              expect(click).toHaveBeenCalledTimes(calledTimes)
              expect(click).toHaveBeenLastCalledWith()

              simEvent.currentTarget = secondLink
              simEvent.target = target

              controller.follow(simEvent)

              expect(link).not.toBe(undefined)
              expect(link).toBe(links[calledTimes])
              expect(link).toBeInstanceOf(HTMLElement)
              expect(link.tagName).toBe("A")
              expect(link.href).toBe(secondLink.href)

              expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(++calledTimes)
              expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(secondLink)
              expect(click).toHaveBeenCalledTimes(calledTimes)
              expect(click).toHaveBeenLastCalledWith()
            }

            for (let i = 0; i < replace.length; i++) {
              const target = replace[i]

              simEvent.currentTarget = secondLink
              simEvent.target = target

              controller.follow(simEvent)

              expect(link).not.toBe(undefined)
              expect(link).toBe(links[calledTimes])
              expect(link).toBeInstanceOf(HTMLElement)
              expect(link.tagName).toBe("A")
              expect(link.href).toBe("sms:+14357534732")

              expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(++calledTimes)
              expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(secondLink)
              expect(click).toHaveBeenCalledTimes(calledTimes)
              expect(click).toHaveBeenLastCalledWith()
            }

            simEvent.currentTarget = secondLink
            simEvent.target = replaceAllDiv

            controller.follow(simEvent)

            expect(link).not.toBe(undefined)
            expect(link).toBe(links[calledTimes])
            expect(link).toBeInstanceOf(HTMLElement)
            expect(link.tagName).toBe("A")
            expect(link.href).toBe("https://downundersports.com/")

            expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(++calledTimes)
            expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(secondLink)



            for (let i = 0; i < nested.length; i++) {
              const [ target, shouldReplace ] = nested[i]

              simEvent.currentTarget = nestedWrapper
              simEvent.target = target

              controller.follow(simEvent)

              expect(link).not.toBe(undefined)
              expect(link).toBe(links[calledTimes])
              expect(link).toBeInstanceOf(HTMLElement)
              expect(link.tagName).toBe("A")
              expect(link.href).toBe(shouldReplace ? "https://youtube.com/" : "https://google.com/")

              expect(controller.getLinkFromTarget).toHaveBeenCalledTimes(++calledTimes)
              expect(controller.getLinkFromTarget).toHaveBeenLastCalledWith(nestedWrapper)
              expect(click).toHaveBeenCalledTimes(calledTimes)
              expect(click).toHaveBeenLastCalledWith()
            }
          })

          it("uses a split string based replacement system using '|'", () => {
            const controller = new DynamicLinkController(),
                  a = document.createElement("A"),
                  div = document.createElement("DIV")

            let link

            Object.defineProperty(controller, "getLinkFromTarget", {
              value: jest.fn().mockImplementation(() => {
                link = document.createElement("A")
                link.href = a.href
                Object.defineProperty(link, "click", {
                  value: jest.fn(),
                  configurable: true,
                })
                return link
              })
            })

            simEvent.currentTarget = a
            simEvent.target = div

            div.dataset.replace = "a|b|c|d|e"
            a.href = "z:/abcde"

            controller.follow(simEvent)

            expect(link.href).toBe("z:/bbdd")

            div.dataset.replace = "a|b|b|d|e|f|g"
            a.href = "z:/abcde"

            controller.follow(simEvent)

            expect(link.href).toBe("z:/dbcdf")

            div.dataset.replace = "z:/|a://|/b|d|b|d|e|f|g"
            a.href = "z:/abcde"

            controller.follow(simEvent)

            expect(link.href).toBe("a://adcdf")
          })
        })

        describe(".getLinkFromTarget", () => {
          const controller = new DynamicLinkController()

          it("throws an error if not given a value that responds to 'querySelectorAll' and 'matches'", () => {
            expect(() => {
              controller.getLinkFromTarget()
            }).toThrow("Cannot read property 'querySelectorAll' of undefined")

            const badValues = [ "", true, false, null, undefined, {}, { querySelectorAll: jest.fn() }, ]

            for(let i = 0; i < badValues.length; i++) {
              expect(() => {
                controller.getLinkFromTarget(badValues[i])
              }).toThrow(/target.querySelectorAll is not a function or its return value is not iterable|Cannot read property 'querySelectorAll' of (?:null|undefined)/)
            }

            const goodValues = [
              {
                querySelectorAll: jest.fn().mockImplementation(() => []),
                matches: () => false
              },
              ...allStandardTags.map(v => document.createElement(v)),
              ...(
                Array.from(Array('Z'.charCodeAt(0) - 'A'.charCodeAt(0) + 1).keys())
                  .map(i =>
                    document.createElement(
                      String.fromCharCode(
                        i + 'A'.charCodeAt(0)
                      )
                    )
                  )
              )
            ]

            for(let i = 0; i < goodValues.length; i++) {
              expect(() => {
                controller.getLinkFromTarget(goodValues[i])
              }).not.toThrow()
            }
          })

          it("uses the given element if it's an anchor tag", () => {
            const controller = new DynamicLinkController(),
                  a = document.createElement("A")

            let result = controller.getLinkFromTarget(a)

            expect(result.href).toBe("http://localhost/#")
            expect(result.target).toBe("")
            expect(result.rel).toBe("")

            a.target = "ASDF"

            result = controller.getLinkFromTarget(a)

            expect(result.href).toBe("http://localhost/#")
            expect(result.href).not.toBe(a.href)
            expect(result.target).toBe("ASDF")
            expect(result.target).toBe(a.target)
            expect(result.rel).toBe("")
            expect(result.rel).toBe(a.rel)

            const hrefs = [,
                    "",
                    "/",
                    "https://google.com",
                    "localhost",
                    "/asdf"
                  ],
                  targets = [
                    "",
                    "_blank",
                    "_self",
                    "_parent",
                    "_top",
                    "asdf",
                    "random"
                  ],
                  rels = [
                    "",
                    "noopener",
                    "noreferrer",
                    "random",
                    "noopener random",
                    "noopener noreferrer",
                  ]

            for(const href of hrefs) {
              for(const target of targets) {
                for(const rel of rels) {
                  a.href = href
                  a.target = target
                  a.rel = rel

                  result = controller.getLinkFromTarget(a)

                  expect(result.href).toBe(a.href)
                  expect(result.target).toBe(a.target)
                  expect(result.rel).toBe(a.rel)

                  a.removeAttribute("href")
                  result = controller.getLinkFromTarget(a)

                  expect(result.href).toBe("http://localhost/#")
                  expect(result.target).toBe(a.target)
                  expect(result.rel).toBe(a.rel)
                }
              }
            }
          })

          it("uses the first anchor child with an [href] property if element is not an anchor", () => {
            const controller = new DynamicLinkController(),
                  div = document.createElement("div"),
                  deleteElement = (el) => div.removeChild(el)

            div.innerHTML = `
              <div id="first-el"></div>
              <a id="first-no-ref"></a>
              <div>
                <a id="first-nested-link" href="/first-nested-link"></a>
              </div>
              <a id="first-outer-link" href="/first-outer-link"></a>
              <a id="second-outer-link" href="/second-outer-link"></a>
              <div>
                <a id="second-nested-link" href="/second-nested-link"></a>
              </div>
            `

            let result = controller.getLinkFromTarget(div)

            expect(result.href).toBe("http://localhost/first-nested-link")

            div.querySelector("#first-nested-link").remove()
            result = controller.getLinkFromTarget(div)

            expect(result.href).toBe("http://localhost/first-outer-link")

            div.querySelector("#first-outer-link").remove()
            result = controller.getLinkFromTarget(div)

            expect(result.href).toBe("http://localhost/second-outer-link")

            div.querySelector("#second-outer-link").remove()
            result = controller.getLinkFromTarget(div)

            expect(result.href).toBe("http://localhost/second-nested-link")
          })

          it("defaults to a local '#' link", () => {
            const controller = new DynamicLinkController(),
                  div = document.createElement("div")

            let result = controller.getLinkFromTarget(div)

            expect(result.href).toBe("http://localhost/#")
            expect(result.target).toBe("")
            expect(result.rel).toBe("")
          })
        })
      })
    })
  })
})
