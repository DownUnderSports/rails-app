// stimuli/controllers/youtube-controller/youtube-controller.js
import { MDCTopAppBar } from '@material/top-app-bar';
import { YoutubeController, youtubeLoaded } from "stimuli/controllers/youtube-controller"
import { sleepAsync } from "helpers/sleep-async"
import { visibility } from "helpers/visibility-state"
import {
          createTemplateController,
          getElements,
          mockScope,
          importScript,
          importScriptImplementation,
          Player,
          playerStates,
          registerController,
          template,
          uniqueId,
          uniqueIdImplementation,
          unregisterController
                                      } from "./_constants"

jest.mock("helpers/import-script")
jest.mock("helpers/unique-id")

uniqueId.mockImplementation(uniqueIdImplementation)
importScript.mockImplementation(importScriptImplementation)

describe("Stimuli", () => {
  describe("Controllers", () => {
    describe("YoutubeController", () => {
      beforeEach(Player.clearMocks)

      it("has keyName 'youtube'", () => {
        expect(YoutubeController.keyName).toEqual("youtube")
      })

      it("has targets for video and placeholder", () => {
        expect(YoutubeController.targets)
          .toEqual([ "wrapper", "video", "placeholder" ])
      })

      describe("lifecycles", () => {
        beforeEach(registerController)
        afterEach(unregisterController)

        describe("on connect", () => {
          it("sets [youtube] to be the controller instance", () => {
            const { wrapper } = getElements()

            expect(wrapper["controllers"]["youtube"])
              .toBeInstanceOf(YoutubeController)
          })

          it("stores the html of [videoTarget] if exists", () => {
            const { wrapper, frame } = getElements(),
                  controller = wrapper["controllers"]["youtube"]

            expect(controller.videoTarget).toBe(frame)
            expect(controller._iframeHTML).toEqual(frame.outerHTML)
          })

          it("sets [pristine] to be true", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"]

            expect(controller.pristine).toBe(true)
          })

          it("sets a class on wrapperTarget with the current state", () => {
            const { wrapper } = getElements()

            expect(wrapper.classList).toContain("unstarted")
          })

          describe("[data-youtube-autoplay] = true", () => {
            beforeEach(async () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              controller.data.set("autoplay", true)
              await controller.loadYoutubeAPI()
              controller.player.onReady()
              await sleepAsync()
            })

            it("starts playing", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(wrapper.classList).not.toContain("unstarted")
              expect(wrapper.classList).toContain("playing")
              expect(controller.player.playVideo).toHaveBeenCalledTimes(1)
              expect(controller.player.playVideo).toHaveBeenLastCalledWith()
            })

            it("starts muted", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(controller.player.mute).toHaveBeenCalledTimes(1)
              expect(controller.player.mute).toHaveBeenLastCalledWith()
              expect(controller.isMuted).toBe(true)
            })

            it("keeps [pristine] true", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(controller.pristine).toBe(true)
            })

            it("disables [pristine] and unmutes on status change", async () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(controller.pristine).toBe(true)
              expect(controller.player.playVideo).toHaveBeenCalledTimes(1)
              expect(controller.player.mute).toHaveBeenCalledTimes(1)
              expect(controller.player.pauseVideo).not.toHaveBeenCalled()
              expect(controller.player.unMute).not.toHaveBeenCalled()

              controller.toggle()
              await sleepAsync()


              expect(wrapper.classList).toContain("paused")
              expect(controller.player.pauseVideo).toHaveBeenCalledTimes(1)
              expect(controller.player.pauseVideo).toHaveBeenLastCalledWith()
              expect(controller.player.unMute).toHaveBeenCalledTimes(1)

              expect(controller.pristine).toBe(false)
              expect(controller.isMuted).toBe(false)

              controller.toggle()
              await sleepAsync()

              expect(wrapper.classList).toContain("playing")
              expect(controller.player.playVideo).toHaveBeenCalledTimes(2)
            })
          })

          describe("[data-youtube-autoplay] = false", () => {
            beforeEach(async () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              controller.data.delete("autoplay")
              controller.player.onReady()
              await sleepAsync()
            })

            it("does not start playing ", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(wrapper.classList).not.toContain("playing")
              expect(wrapper.classList).toContain("unstarted")
              expect(controller.player.playVideo).not.toHaveBeenCalled()
            })

            it("sets [pristine] false", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(controller.pristine).toBe(false)
            })

            it("is not muted", () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              expect(controller.player.mute).not.toHaveBeenCalled()
              expect(controller.isMuted).toBe(false)
            })
          })
        })

        describe("on disconnect", () => {
          it("removes [youtube] from the element", async () => {
            const { wrapper } = getElements()
            expect(wrapper["controllers"]["youtube"]).toBeInstanceOf(YoutubeController)
            await wrapper["controllers"]["youtube"].disconnect()
            expect(wrapper["controllers"]["youtube"]).toBe(undefined)
          })

          it("calls #destroy on .player", async () => {
            const { wrapper } = getElements(),
                  player = wrapper["controllers"]["youtube"].player,
                  destroy = player.destroy,
                  mock = jest.fn()
                    .mockImplementation(destroy)
                    .mockName("destroy")

            Object.defineProperty(player, "destroy", {
              value: mock,
              configurable: true
            })

            await wrapper["controllers"]["youtube"].disconnect()

            expect(mock).toHaveBeenCalledTimes(1)
            expect(mock).toHaveBeenLastCalledWith()

            if(player.hasOwnProperty("destroy")) delete player.destroy
          })
        })
      })

      describe("getters/setters", () => {
        describe("[wrapperTargetId]", () => {
          it("returns [id] from [wrapperTarget])", () => {
            const controller = new YoutubeController(),
                  wrapper = document.createElement("div")

            wrapper.id = "test-youtube"

            mockScope(controller, wrapper)

            expect(() => controller.wrapperTargetId).toThrow(Error)
            expect(() => controller.wrapperTargetId).toThrow(new Error(`Missing target element "youtube.wrapper"`))

            wrapper.dataset.target = "youtube.wrapper"

            expect(controller.wrapperTargetId).toEqual("test-youtube")
            wrapper.id = Math.random()
            expect(controller.wrapperTargetId).not.toEqual("test-youtube")
            expect(controller.wrapperTargetId).toMatch(/^0\.[0-9]+$/)
            expect(controller.wrapperTargetId).toBe(wrapper.id)
          })

          it("sets a uniqueId if [wrapperTarget][id] is empty", () => {
            const controller = new YoutubeController(),
                  wrapper = document.createElement("div")

            mockScope(controller, wrapper)
            wrapper.dataset.target = "youtube.wrapper"

            uniqueIdImplementation.i = 0
            for(let n = 1; n < 6; n++) {
              wrapper.removeAttribute("id")
              expect(wrapper.id).toEqual("")
              expect(controller.wrapperTargetId).toEqual(`unique-id-${n}`)
              expect(wrapper.id).toEqual(`unique-id-${n}`)
            }
          })
        })

        describe("[playing]", () => {
          it("returns [playerState] === 1", () => {
            const controller = new YoutubeController()
            let currentState = -1

            controller.player = {
              getPlayerState: jest.fn().mockImplementation(() => currentState)
            }

            expect(controller.playing).toBe(false)
            currentState = 1
            expect(controller.player.getPlayerState).toHaveBeenCalledTimes(1)
            expect(controller.playing).toBe(true)
            expect(controller.player.getPlayerState).toHaveBeenCalledTimes(2)
          })

          it("returns -1 if ![player]", () => {
            let tmpState = -1, callCount = 0
            const controller = new YoutubeController()

            expect(controller.playerState).toBe(-1)
          })
        })

        describe("[playerState]", () => {
          it("returns [player].getPlayerState if [player]", () => {
            const controller = new YoutubeController()

            controller.player = {
              getPlayerState: jest.fn().mockImplementation(() => 1)
            }

            expect(controller.playerState).toBe(1)
            expect(controller.player.getPlayerState).toHaveBeenCalledTimes(1)
            expect(controller.player.getPlayerState).toHaveBeenLastCalledWith()
          })

          it("returns -1 if ![player]", () => {
            let tmpState = -1, callCount = 0
            const controller = new YoutubeController()

            expect(controller.playerState).toBe(-1)
          })
        })

        describe("[playerStateName]", () => {
          it("translates [playerState] to a human readable name", () => {
            let tmpState = -1, callCount = 0
            const controller = new YoutubeController(),
                  playerStateMock = jest.fn().mockImplementation(() => tmpState)

            Object.defineProperty(controller, "playerState", {
              get: playerStateMock
            })

            for(let state in playerStates) {
              tmpState = playerStates[state];
              expect(controller.playerStateName).toBe(state)
              expect(playerStateMock).toHaveBeenCalledTimes(++callCount)
            }
          })
        })

        describe("[YT]", () => {
          it("is a wrapper for window.YT", () => {
            const controller = new YoutubeController()
            const yt = window.YT,
                  fakeYT = {}
            try {
              window.YT = fakeYT
              expect(controller.YT).toBe(fakeYT)
            } finally {
              window.YT = yt
            }
          })
        })

        describe("[videoIds]", () => {
          it("is the comma split list of [data-youtube-ids] from element)", () => {
            const controller = new YoutubeController(),
                  wrapper = document.createElement("div")

            mockScope(controller, wrapper)

            expect(() => controller.videoIds).toThrow(TypeError)
            expect(() => controller.videoIds).toThrow(new TypeError("Cannot read property 'split' of null"))

            wrapper.dataset.youtubeIds = "ord,er,ing"
            expect(controller.videoIds).toEqual([ "ord", "er", "ing" ])

            wrapper.dataset.youtubeIds = "CaP,iTa,LiZ,atiON"
            controller.resetVideoIds()
            expect(controller.videoIds).toEqual([ "CaP", "iTa", "LiZ", "atiON" ])

            wrapper.dataset.youtubeIds = "spacing and, $p3c1al, Character5 "
            controller.resetVideoIds()
            expect(controller.videoIds).toEqual([ "spacing and", "$p3c1al", "Character5" ])
          })
        })

        describe("[videoId]", () => {
          it("is the first id in [videoIds]", () => {
            const controller = new YoutubeController()

            Object.defineProperty(controller, "videoIds", {
              value: [ "firstId", "secondId" ]
            })

            expect(controller.videoId).toEqual("firstId")

            controller.videoIds.shift()

            expect(controller.videoId).toEqual("secondId")

            controller.videoIds.unshift("newFirstId")

            expect(controller.videoId).toEqual("newFirstId")
          })
        })

        describe("[isMuted]", () => {
          beforeEach(registerController)
          afterEach(unregisterController)

          it("returns .isMuted from [player]", async () => {
            let currentPlayer

            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"],
                  player = controller.player,
                  get = jest.fn().mockImplementation(() => currentPlayer),
                  set = jest.fn().mockImplementation(value => currentPlayer = value)
            try {
              Object.defineProperty(controller, "player", {
                get,
                set,
                configurable: true,
              })

              player.unMute()

              player.clearMocks()
              get.mockClear()
              set.mockClear()

              expect(controller.isMuted).toBe(undefined)
              expect(get).toHaveBeenCalledTimes(1)
              expect(player.isMuted).not.toHaveBeenCalled()

              currentPlayer = player

              expect(controller.isMuted).toBe(false)
              expect(get).toHaveBeenCalledTimes(3)
              expect(player.isMuted).toHaveBeenCalledTimes(1)

              player.mute()

              expect(controller.isMuted).toBe(true)
              expect(get).toHaveBeenCalledTimes(5)
              expect(player.isMuted).toHaveBeenCalledTimes(2)
            } finally {
              Object.defineProperty(controller, "player", {
                value: player,
                configurable: true,
                writable: true
              })
            }
          })
        })
      })

      describe("listeners", () => {
        describe(".onVisibilityChange", () => {
          const truthy = [ true, 1, "truthy" ],
                falsy = [ false, 0, "", null, undefined ];

          describe("[pristine] truthy", () => {
            describe("arg[0] === 'visible'", () => {
              it("calls .onReady", () => {
                const controller = new YoutubeController()
                controller.onReady = jest.fn()
                controller.pause = jest.fn()

                truthy.forEach(truth => {
                  controller.onReady.mockClear()
                  controller.pause.mockClear()
                  controller.pristine = truth

                  expect(controller.onVisibilityChange("visible")).toBe(undefined)
                  expect(controller.onReady).toHaveBeenCalledTimes(1)
                  expect(controller.pause).not.toHaveBeenCalled()
                })
              })
            })

            describe("arg[0] !== 'visible'", () => {
              it("calls .pause", () => {
                const controller = new YoutubeController()
                controller.onReady = jest.fn()
                controller.pause = jest.fn()

                truthy.forEach(truth => {
                  controller.onReady.mockClear()
                  controller.pause.mockClear()
                  controller.pristine = truth

                  expect(controller.onVisibilityChange("hidden")).toBe(undefined)
                  expect(controller.onVisibilityChange(true)).toBe(undefined)
                  expect(controller.onVisibilityChange(false)).toBe(undefined)
                  expect(controller.onVisibilityChange()).toBe(undefined)
                  expect(controller.pause).toHaveBeenCalledTimes(4)
                  expect(controller.onReady).not.toHaveBeenCalled()
                })
              })
            })
          })

          describe("[pristine] falsy", () => {
            it("does nothing", () => {
              const controller = new YoutubeController()
              controller.onReady = jest.fn()
              controller.pause = jest.fn()

              falsy.forEach(lie => {
                controller.onReady.mockClear()
                controller.pause.mockClear()
                controller.pristine = lie

                expect(controller.onVisibilityChange("visible")).toBe(undefined)
                expect(controller.onVisibilityChange()).toBe(undefined)
                expect(controller.onReady).not.toHaveBeenCalled()
                expect(controller.pause).not.toHaveBeenCalled()
              })
            })
          })
        })

        describe(".onReady", () => {
          let controller, autoplay
          beforeEach(async () => {
            controller = new YoutubeController()
            controller.mute = jest.fn()
            controller.play = jest.fn()
            Object.defineProperty(controller, "data", {
              get: jest
                .fn()
                .mockImplementation(() => ({
                  get: jest.fn().mockImplementation(() => autoplay)
                }))
            })
            controller.pristine = true
            await sleepAsync()
          })

          describe("[data-youtube-autoplay]", () => {
            beforeEach(() => autoplay = true)

            describe("visibility.state === 'visible'", () => {
              it("calls .mute and .play", () => {
                visibility.state = "visible"

                expect(controller.onReady()).toBe(undefined)
                expect(controller.play).toHaveBeenCalledTimes(1)
                expect(controller.mute).toHaveBeenCalledTimes(1)
                expect(controller.pristine).toBe(true)
              })
            })

            describe("visibility.state !== 'visible'", () => {
              it("does nothing", () => {
                visibility.state = "hidden"

                expect(controller.onReady()).toBe(undefined)
                expect(controller.play).not.toHaveBeenCalled()
                expect(controller.mute).not.toHaveBeenCalled()
                expect(controller.pristine).toBe(true)
              })
            })
          })

          describe("![data-youtube-autoplay]", () => {
            beforeEach(() => autoplay = false)

            it("sets [pristine] = true", () => {
              visibility.state = "hidden"

              expect(controller.onReady()).toBe(undefined)
              expect(controller.play).not.toHaveBeenCalled()
              expect(controller.mute).not.toHaveBeenCalled()
              expect(controller.pristine).toBe(false)
            })
          })
        })

        describe(".onStateChange", () => {
          let controller, playerState, autoplay, muted, clearMocks
          const videoIds = [1,2,3]
          beforeEach(async () => {
            const { wrapper } = getElements()
            controller = new YoutubeController()
            controller.unMute = jest.fn()
            controller.mute = jest.fn()
            controller.play = jest.fn()
            controller.setWrapperClass = jest.fn()
            controller.resetVideoIds = jest.fn().mockImplementation(() => {
              videoIds.splice(0)
              videoIds.push(1,2,3)
            })
            controller.player = new Player()
            videoIds.shift = jest.fn().mockImplementation(() => {
              const [ id ] = videoIds.splice(0, 1)
              return id
            })
            Object.defineProperty(controller, "playerState", {
              get: jest.fn().mockImplementation(() => playerState),
              set: jest.fn().mockImplementation((v) => playerState = v)
            })
            Object.defineProperty(controller, "wrapperTarget", {
              get: jest.fn().mockImplementation(() => wrapper)
            })
            Object.defineProperty(controller, "isMuted", {
              get: jest.fn().mockImplementation(() => muted)
            })
            Object.defineProperty(controller, "videoIds", {
              get: jest.fn().mockImplementation(() => videoIds)
            })
            Object.defineProperty(controller, "data", {
              get: jest
                .fn()
                .mockImplementation(() => ({
                  get: jest.fn().mockImplementation(() => autoplay)
                }))
            })

            clearMocks = () => {
              playerState = playerStates.paused
              visibility.state = "visible"
              autoplay = true
              muted = true
              controller.pristine = true
              controller.resetVideoIds()

              controller.unMute.mockClear()
              controller.mute.mockClear()
              controller.play.mockClear()
              controller.resetVideoIds.mockClear()
              controller.setWrapperClass.mockClear()
              videoIds.shift.mockClear()
            }

            clearMocks()
            await sleepAsync()
          })

          it("calls .setWrapperClass with [playerState]", () => {
            let called = 0
            for(let state in playerStates) {
              playerState = playerStates[state]
              expect(controller.onStateChange()).toBe(undefined)
              expect(controller.setWrapperClass).toHaveBeenCalledTimes(++called)
              expect(controller.setWrapperClass).toHaveBeenLastCalledWith(playerState)
            }
          })

          describe("[playerState] is paused, [isMuted], [pristine], [data-youtube-autoplay], and visibility.state === 'visible'", () => {
            it("calls .unMute", () => {
              expect(controller.onStateChange()).toBe(undefined)
              expect(controller.unMute).toHaveBeenCalledTimes(1)
            })

            it("sets [pristine] false", () => {
              expect(controller.onStateChange()).toBe(undefined)
              expect(controller.pristine).toBe(false)
            })
          })

          const otherStates = [
            [ () => playerState = -1, `![playerState] paused` ],
            [ () => visibility.state = "hidden", `visibility.state !== "visible"` ],
            [ () => autoplay = false, `![data-youtube-autoplay]` ],
            [ () => muted = false, `![isMuted]` ],
            [ () => controller.pristine = false, `![pristine]` ],
          ]

          for (let i = 0; i < otherStates.length; i++) {
            const [ func, desc ] = otherStates[i]
            describe(`${desc}`, () => {
              beforeEach(func)
              describe("[playerState] ended && [videoIds] present", () => {
                beforeEach(() => {
                  playerState = playerStates.ended
                })

                it("calls shift on [videoIds]", () => {
                  expect(controller.onStateChange()).toBe(undefined)
                  expect(controller.unMute).not.toHaveBeenCalled()
                  expect(controller.videoIds.shift).toHaveBeenCalledTimes(1)
                })

                describe("[videoIds][length] > 1", () => {
                  it("loads the next video in the list", () => {
                    expect(controller.onStateChange()).toBe(undefined)
                    expect(controller.unMute).not.toHaveBeenCalled()
                    expect(controller.videoIds.shift).toHaveBeenCalledTimes(1)
                    expect(controller.resetVideoIds).not.toHaveBeenCalled()
                    expect(controller.player.loadVideoById).toHaveBeenCalledTimes(1)
                    expect(controller.player.loadVideoById).toHaveBeenLastCalledWith(2)
                  })
                })

                describe("[videoIds][length] === 1", () => {
                  beforeEach(() => {
                    videoIds.splice(0)
                    videoIds.push(3)
                  })

                  it("resets the video list", () => {
                    expect(controller.onStateChange()).toBe(undefined)
                    expect(controller.unMute).not.toHaveBeenCalled()
                    expect(controller.videoIds.shift).toHaveBeenCalledTimes(1)
                    expect(controller.resetVideoIds).toHaveBeenCalledTimes(1)
                    expect(controller.player.loadVideoById).not.toHaveBeenCalled()
                    expect(controller.player.cueVideoById).toHaveBeenCalledTimes(1)
                    expect(controller.player.cueVideoById).toHaveBeenLastCalledWith(1)
                  })
                })
              })

              describe("![playerState] ended || ![videoIds] present", () => {
                it("does nothing else", () => {
                  [
                    () => {
                      playerState = playerStates.ended
                      videoIds.splice(0)
                    },
                    () => {
                      playerState = playerStates.buffering
                      videoIds.push(0)
                    }
                  ].map(func => {
                    func()
                    const pristine = controller.pristine
                    expect(controller.onStateChange()).toBe(undefined)
                    expect(controller.unMute).not.toHaveBeenCalled()
                    expect(controller.resetVideoIds).not.toHaveBeenCalled()
                    expect(controller.pristine).toBe(pristine)
                  })
                })
              })
            })
          }
        })
      })

      describe("actions", () => {
        beforeEach(async () => {
          await registerController()
          const { wrapper } = getElements(),
                controller = wrapper["controllers"]["youtube"]

          controller.data.delete("autoplay")
          controller.player.onReady()
          controller.player.clearMocks()
          await sleepAsync()
        })
        afterEach(unregisterController)

        describe(".toggle", () => {
          beforeEach(async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"]

            controller.player.clearMocks()
            await sleepAsync()
          })

          it("toggles the current playing state", async () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"]

            expect(wrapper.classList).toContain("unstarted")
            expect(wrapper.classList).not.toContain("paused")
            expect(wrapper.classList).not.toContain("playing")
            expect(controller.player.playVideo).not.toHaveBeenCalled()
            expect(controller.player.pauseVideo).not.toHaveBeenCalled()

            controller.toggle()
            await sleepAsync()

            expect(wrapper.classList).toContain("playing")
            expect(wrapper.classList).not.toContain("unstarted")
            expect(wrapper.classList).not.toContain("paused")
            expect(controller.player.pauseVideo).not.toHaveBeenCalled()
            expect(controller.player.playVideo).toHaveBeenCalledTimes(1)

            controller.toggle()
            await sleepAsync()

            expect(wrapper.classList).toContain("paused")
            expect(wrapper.classList).not.toContain("unstarted")
            expect(wrapper.classList).not.toContain("playing")
            expect(controller.player.pauseVideo).toHaveBeenCalledTimes(1)
          })
        })

        const methods = [
          [ "mute", "mute" ],
          [ "unMute", "unMute" ],
          [ "play", "playVideo" ],
          [ "pause", "pauseVideo" ]
        ]

        for (let i = 0; i < methods.length; i++) {
          const [ method, proxy ] = methods[i];

          describe(`.${method}`, () => {
            beforeEach(async () => {
              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"]

              controller.player.clearMocks()
              await sleepAsync()
            })

            it(`calls ${proxy} on [player]`, async () => {
              let currentPlayer

              const { wrapper } = getElements(),
                    controller = wrapper["controllers"]["youtube"],
                    player = controller.player,
                    get = jest.fn().mockImplementation(() => currentPlayer),
                    set = jest.fn().mockImplementation(value => currentPlayer = value),
                    onStateChange = player.onStateChange
              try {
                player.onStateChange = () => {}

                Object.defineProperty(controller, "player", {
                  get,
                  set,
                  configurable: true,
                })

                player.unMute()
                player.playVideo()

                await sleepAsync()

                player.clearMocks()
                get.mockClear()
                set.mockClear()

                expect(controller[method]()).toBe(undefined)
                expect(get).toHaveBeenCalledTimes(1)
                expect(player[proxy]).not.toHaveBeenCalled()

                currentPlayer = player
                const value = player[proxy]()

                player.clearMocks()

                for (let i = 1; i < 5; i++) {
                  expect(controller[method]()).toBe(value)
                  expect(get).toHaveBeenCalledTimes((i*2) + 1)
                  expect(player[proxy]).toHaveBeenCalledTimes(i)
                }

              } finally {
                player.onStateChange = onStateChange

                Object.defineProperty(controller, "player", {
                  value: player,
                  configurable: true,
                  writable: true
                })
              }
            })
          })
        }

        describe(".resetVideoIds", () => {
          it("sets [videoIds] back to default", () => {
            const { wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"]

            controller._videoIds = []

            expect(controller.videoIds).toEqual([])

            controller.resetVideoIds()

            expect(controller.videoIds).toEqual(["Yh5CjpY35BM","C-gkKvFNL88"])
          })
        })

        describe(".setWrapperClass", () => {
          it("enables a matching class for arg[0] and disables all others", () => {
            const wrapper = document.createElement("DIV"),
                  controller = new YoutubeController(),
                  enableAll = () => {
                    for(let state in playerStates) {
                      wrapper.classList.toggle(state, true)
                      expect(wrapper.classList.contains(state)).toBe(true)
                    }
                  },
                  disableAll = () => {
                    for(let state in playerStates) {
                      wrapper.classList.toggle(state, false)
                      expect(wrapper.classList.contains(state)).toBe(false)
                    }
                  },
                  checkClassSettings = (state) => {
                    controller.setWrapperClass(playerStates[state])
                    expect(wrapper.classList.contains(state)).toBe(true)
                    for(let subState in playerStates) {
                      expect(wrapper.classList.contains(subState)).toBe(subState === state)
                    }
                  }

            Object.defineProperty(controller, "wrapperTarget", {
              value: wrapper
            })

            enableAll()
            for(let state in playerStates) {
              enableAll()
              checkClassSettings(state)
              disableAll()
              checkClassSettings(state)
            }
          })
        })

        describe(".getPlayerTarget", () => {
          it("returns [videoTarget] if [hasVideoTarget]", () => {
            const { frame, wrapper } = getElements(),
                  controller = wrapper["controllers"]["youtube"]
            expect(controller.getPlayerTarget()).toBe(frame)
          })

          it("creates [videoTarget] if ![hasVideoTarget] and was connected with a videoTarget", () => {
            const wrapper = document.createElement("DIV"),
                  html = `<p id="tmp">INNERHTML</p>`
            const controller = new YoutubeController()
            controller._iframeHTML = html
            Object.defineProperty(controller, "wrapperTarget", {
              get: jest.fn().mockImplementation(() => wrapper)
            })
            Object.defineProperty(controller, "videoTarget", {
              get: jest.fn().mockImplementation(() => wrapper.querySelector("p#tmp"))
            })
            Object.defineProperty(controller, "hasVideoTarget", {
              get: jest.fn()
                .mockImplementationOnce(() => false)
                .mockImplementationOnce(() => !!wrapper.querySelector("p#tmp"))
            })

            expect(controller.videoTarget).toBe(null)

            const result = controller.getPlayerTarget()

            expect(result).toBe(wrapper.querySelector("p#tmp"))
            expect(result).toBe(controller.videoTarget)
          })

          it("returns [wrapperTargetId] if ![hasVideoTarget]", () => {
            const controller = new YoutubeController(),
                  wrapperTargetId = jest.fn().mockImplementation(() => "fake-id")

            Object.defineProperty(controller, "wrapperTargetId", {
              get: wrapperTargetId
            })
            Object.defineProperty(controller, "hasVideoTarget", {
              get: jest.fn().mockImplementation(() => false)
            })

            expect(controller.getPlayerTarget()).toBe("fake-id")
            expect(wrapperTargetId).toHaveBeenCalledTimes(1)
          })
        })

        describe(".createPlayer", () => {
          it("returns [player] if [player]", () => {
            const controller = new YoutubeController(),
                  player = new Player()
            controller.player = player

            expect(controller.player).toBe(player)
            controller.createPlayer()
            expect(controller.player).toBe(player)
          })

          it("creates a new [YT][Player] if ![player]", () => {
            const controller = new YoutubeController(),
                  playerSubMock = jest.fn().mockImplementation((...args) => new Player(...args)),
                  videoIdMock = jest.fn().mockImplementation(() => "fakeVideoId"),
                  playerTargetMock = jest.fn().mockImplementation(() => "fakeTargetId")

            Object.defineProperty(controller, "YT", {
              value: {
                Player: playerSubMock
              }
            })

            Object.defineProperty(controller, "videoId", {
              get: videoIdMock
            })

            Object.defineProperty(controller, "getPlayerTarget", {
              value: playerTargetMock
            })

            const expected = {
              videoId: "fakeVideoId",
              host: "https://www.youtube-nocookie.com",
              playerVars: {
                modestbranding: 1,
                start: 0,
                domain: window.location.origin,
                enablejsapi: 1,
                autoplay: 0
              },
              events: {
                onReady: controller.onReady,
                onStateChange: controller.onStateChange
              }
            }

            expect(controller.player).toBe(undefined)
            controller.createPlayer()
            expect(controller.player).toBeInstanceOf(Player)
            expect(playerSubMock).toHaveBeenCalledTimes(1)
            expect(playerSubMock).toHaveBeenLastCalledWith("fakeTargetId", expected)

            expect(videoIdMock).toHaveBeenCalledTimes(1)
            expect(playerTargetMock).toHaveBeenCalledTimes(1)
            expect(playerTargetMock).toHaveBeenLastCalledWith()
          })
        })

        describe(".loadYoutubeAPI", () => {
          it("loads the youtube API", async () => {
            importScript.mockClear()

            const controller = new YoutubeController()

            expect(importScript).not.toHaveBeenCalled()

            await controller.loadYoutubeAPI()

            expect(importScript).toHaveBeenCalledTimes(1)
            expect(importScript).toHaveBeenLastCalledWith("https://www.youtube.com/iframe_api")

            await controller.loadYoutubeAPI()
            expect(importScript).toHaveBeenCalledTimes(2)
            expect(importScript).toHaveBeenLastCalledWith("https://www.youtube.com/iframe_api")
          })

          describe("if [_isConnected]", () => {
            it("adds a visibility listener and creates [player] after loading youtube API", async () => {
              const addEventListener = visibility.addEventListener
              try {
                const controller = new YoutubeController()

                controller._isConnected = true
                visibility.addEventListener = jest.fn()

                Object.defineProperty(controller, "createPlayer", {
                  value: jest.fn()
                })

                await controller.loadYoutubeAPI()

                expect(controller.createPlayer).toHaveBeenCalledTimes(1)
                expect(visibility.addEventListener).toHaveBeenCalledTimes(1)
                expect(visibility.addEventListener).toHaveBeenLastCalledWith(controller.onVisibilityChange)
              } finally {
                visibility.addEventListener = addEventListener
              }
            })
          })

          describe("if ![_isConnected]", () => {
            it("adds a visibility listener and creates [player] after loading youtube API", async () => {
              const addEventListener = visibility.addEventListener
              try {
                const controller = new YoutubeController()

                controller._isConnected = false
                visibility.addEventListener = jest.fn()

                Object.defineProperty(controller, "createPlayer", {
                  value: jest.fn()
                })

                await controller.loadYoutubeAPI()

                expect(controller.createPlayer).not.toHaveBeenCalled()
                expect(visibility.addEventListener).not.toHaveBeenCalled()
              } finally {
                visibility.addEventListener = addEventListener
              }
            })
          })
        })
      })
    })
  })
})
