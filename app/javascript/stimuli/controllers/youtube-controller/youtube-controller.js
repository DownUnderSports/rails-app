import { Controller } from "stimuli"
import { visibility } from "helpers"

let youtubeReady  = null,
    youtubeFailed = null,
    ytAPIStarted  = null

const youtubeLoaded = new Promise((resolve, reject) => {
  youtubeReady = resolve
  youtubeFailed = reject
})

window.onYouTubeIframeAPIReady = () => youtubeReady()

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

export class YoutubeController extends Controller {
  static keyName = "youtube"
  static targets = [ "wrapper", "video", "placeholder" ]

  async connect() {
    this.disconnected = false
    this.pristine = true
    this.wrapperTarget.classList.toggle("youtube", true)
    this.onStateChange({ data: playerStates.unstarted })
    this.loadYoutubeAPI()
  }

  disconnect() {
    this.disconnected = true
    visibility.removeEventListener(this.onVisibilityChange)
  }

  // Private
  async loadYoutubeAPI() {
    if(!ytAPIStarted) {
      ytAPIStarted = true
      // 2. This code loads the IFrame Player API code asynchronously.
      const tag = document.createElement('script');

      tag.src = "https://www.youtube.com/iframe_api";
      document.body.appendChild(tag)
    }
    await youtubeLoaded
    if(!this.disconnected) {
      this.createPlayer()
      visibility.addEventListener(this.onVisibilityChange)
    }
  }

  createPlayer = () => {
    this.player = this.player || new this.YT.Player(this.videoTarget, {
      videoId: this.videoId,
      playerVars: {
        modestbranding: 1,
        start: 0,
        domain: window.location.origin,
        enablejsapi: 1,
        autoplay: 1
      },
      events: {
        onReady: this.onReady,
        onStateChange: this.onStateChange
      }
    })
  }

  onReady = (ev) => {
    if(this.data.get("autoplay")) {
      this.mute()
      this.play()
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
      && this.isMuted()
      && visibility.state === "visible"
    ) {
      this.pristine = false
      this.unMute()
      // this.play()
    } else if(current === playerStates.ended && this.videoIds.length) {
      this.videoIds.shift()
      if(this.videoId) this.player.loadVideoById(this.videoId)
      else {
        this.resetVideoIds
        this.player.cueVideoById(this.videoId)
      }
    }
  }

  setWrapperClass = (id) => {
    for(let k in playerStates) {
      this.wrapperTarget.classList.toggle(k, playerStates[k] === id)
    }
  }

  toggle = () => this.playing ? this.pause() : this.play()

  isMuted = () => this.player && this.player.isMuted()

  mute = () => this.player && this.player.mute()

  unMute = () => this.player && this.player.unMute()

  play = () => this.player && this.player.playVideo()

  pause = () => this.player && this.player.pauseVideo()

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
    return this._videoIds = this._videoIds || this.resetVideoIds
  }

  get resetVideoIds() {
    return this._videoIds = this.data.get("ids").split(",")
  }

  get videoId() {
    return this.videoIds[0]
  }
}

YoutubeController.registerController()
