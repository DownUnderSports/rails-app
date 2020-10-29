import { YoutubeController } from "stimuli/controllers/youtube-controller"
import { Scope } from "test-helpers/mocks/stimulus/scope"
import { Player } from "test-helpers/mocks/yt/player"
export { importScript } from "helpers/import-script"
export { uniqueId } from "helpers/unique-id"

YoutubeController.bless()

let i = 0
export const uniqueIdImplementation = () => `unique-id-${++i}`

export const importScriptImplementation = async () => {
  window.YT = window.YT || { Player }
  window.onYouTubeIframeAPIReady && window.onYouTubeIframeAPIReady()
  return await Promise.resolve()
}

Object.defineProperty(uniqueIdImplementation, "i", {
  get: () => i,
  set: v => i = v,
  configurable: false
})

export const getElements = () => {
  const wrapper = document.getElementById("test-youtube"),
        frame = wrapper.querySelector("iframe")

  return { wrapper, frame }
}

export const playerStates = {
  unstarted: -1,
  ended:     0,
  playing:   1,
  paused:    2,
  buffering: 3,
  queued:    5,
}

export const template = `
  <div
    id="test-youtube"
    data-controller="youtube"
    data-target="youtube.wrapper"
    data-youtube-autoplay="true"
    data-action="click->youtube#toggle"
    data-youtube-ids="Yh5CjpY35BM,C-gkKvFNL88"
    class="mdc-card__media mdc-card__media--16-9 youtube">
    <iframe
      data-action="click->youtube#toggle"
      data-target="youtube.video"
      class="mdc-card__media-content"
      src="https://www.youtube-nocookie.com/embed/Yh5CjpY35BM?rel=0&mute=1&enablejsapi=1&modestbranding=1"
      frameborder="0"
      allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen
    ></iframe>
  </div>
`

export const mockScope = async (controller, element) => {
  const scope = new Scope(YoutubeController.keyName, element)

  Object.defineProperty(controller, "scope", {
    value: scope,
    configurable: true,
    writable: true
  })
}

export const createTemplateController = () => {
  document.body.innerHTML = template
  const { wrapper } = getElements()
  const controller = new YoutubeController()
  mockScope(controller, wrapper)
  return controller
}

export const registerController = () => {
  document.body.innerHTML = template

  Player.clearMocks()

  YoutubeController.registerController()
}

export { Player }
