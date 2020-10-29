import { Controller } from "stimuli/constants/controller"
import { visibility, uniqueId, importScript } from "helpers"

export const youtubeLoaded = new Promise(resolve => {
  window.onYouTubeIframeAPIReady = resolve
})

const playerStates = {
  unstarted: -1,
  ended:     0,
  playing:   1,
  paused:    2,
  buffering: 3,
  queued:    5,
}

const playerStateIds = {}

for(let state in playerStates) {
  playerStateIds[playerStates[state]] = state
}

const ignoreErrors = (cb) => {
  try { cb() } catch(_) {}
}

export class YoutubeController extends Controller {
  static keyName = "youtube"
  static targets = [ "wrapper", "video", "placeholder" ]

  async connected() {
    this.pristine = true
    this.wrapperTarget.classList.toggle("youtube", true)
    if(this.hasVideoTarget) this._iframeHTML = this.videoTarget.outerHTML
    this.onStateChange()
    this.loadYoutubeAPI()
  }

  async disconnected() {
    visibility.removeEventListener(this.onVisibilityChange)
    this.player && await this.player.destroy()
    this.player = null
  }

  onVisibilityChange = (state) => {
    if(this.pristine) {
      if(state === "visible") this.onReady()
      else this.pause()
    }
  }

  onReady = (ev) => {
    if(this.data.get("autoplay")) {
      if(visibility.state === "visible") {
        this.mute()
        this.play()
      }
    } else {
      this.pristine = false
    }
  }

  onStateChange = () => {
    const current = this.playerState

    this.setWrapperClass(current)

    if(
      this.pristine
      && this.data.get("autoplay")
      && current === playerStates.paused
      && this.isMuted
      && visibility.state === "visible"
    ) {
      this.pristine = false
      this.unMute()
      // this.play()
    } else if(current === playerStates.ended && this.videoIds.length) {
      this.videoIds.shift()
      if(this.videoId) this.player.loadVideoById(this.videoId)
      else {
        this.resetVideoIds()
        this.player.cueVideoById(this.videoId)
      }
    }
  }

  // Private
  async loadYoutubeAPI() {
    await importScript("https://www.youtube.com/iframe_api")
    await youtubeLoaded
    if(!this._disconnected) {
      visibility.addEventListener(this.onVisibilityChange)
      this.createPlayer()
    }
  }

  getPlayerTarget = () => {
    if(!this.hasVideoTarget && this._iframeHTML) {
      this.wrapperTarget.innerHTML = this.wrapperTarget.innerHTML + this._iframeHTML
    }
    return this.hasVideoTarget ? this.videoTarget : this.wrapperTargetId
  }

  createPlayer = () => {
    this.player = this.player || new this.YT.Player(this.getPlayerTarget(), {
      videoId: this.videoId,
      host: "https://www.youtube-nocookie.com",
      playerVars: {
        modestbranding: 1,
        start: 0,
        domain: window.location.origin,
        enablejsapi: 1,
        autoplay: 0
      },
      events: {
        onReady: this.onReady,
        onStateChange: this.onStateChange
      }
    })
  }

  setWrapperClass = (id) => {
    for(let k in playerStates) {
      this.wrapperTarget.classList.toggle(k, playerStates[k] === id)
    }
  }

  toggle = () => this.playing ? this.pause() : this.play()

  mute = () => this.player && this.player.mute()

  unMute = () => this.player && this.player.unMute()

  play = () => this.player && this.player.playVideo()

  pause = () => this.player && this.player.pauseVideo()

  resetVideoIds = () => this._videoIds = this.data.get("ids").split(",").map(v => v.replace(/^\s+|\s+$/g, ""))

  get wrapperTargetId() {
    if(this.wrapperTarget.id) return this.wrapperTarget.id
    this.wrapperTarget.id = uniqueId()
    return this.wrapperTarget.id
  }

  get playing() {
    return this.playerState === playerStates.playing
  }

  get playerState() {
    return this.player ? this.player.getPlayerState() : -1
  }

  get playerStateName() {
    return playerStateIds[this.playerState]
  }

  get YT () {
    return window.YT
  }

  get videoIds() {
    return this._videoIds = this._videoIds || this.resetVideoIds()
  }

  get videoId() {
    return this.videoIds[0]
  }

  get isMuted() {
    return this.player && this.player.isMuted()
  }
}
