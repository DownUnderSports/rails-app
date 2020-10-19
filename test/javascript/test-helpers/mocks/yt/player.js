const mocked = []

class Player {
  get playerState() {
    return this._playerState || -1
  }

  set playerState(value) {
    this._playerState = value
    this.onStateChange(this.playerState)
    return this.playerState
  }

  get muted() {
    return !!this._muted
  }

  set muted(value) {
    return this._muted = !!value
  }

  get currentVideo() {
    return this._currentVideo
  }

  set currentVideo(value) {
    return this._currentVideo = value
  }

  get events() {
    return (this.props && this.props.events) || {}
  }

  constructor(frame, props) {
    const instance = this
    this.el = frame
    this.props = props
    this.getPlayerState = jest.fn().mockImplementation(() => instance.playerState)
    this.isMuted = jest.fn().mockImplementation(() => instance.muted),
    this.mute = jest.fn().mockImplementation(() => instance.muted = true),
    this.unMute = jest.fn().mockImplementation(() => instance.muted = false),
    this.playVideo = jest.fn().mockImplementation(() => instance.playerState = 1),
    this.pauseVideo = jest.fn().mockImplementation(() => instance.playerState = 2),
    this.cueVideoById = jest.fn().mockImplementation(id => instance.currentVideo = id),
    this.loadVideoById = jest.fn().mockImplementation(id => { instance.cueVideoById(id); return instance.playVideo() })
    this.onStateChange = (ps) => {
      this.events.onStateChange && this.events.onStateChange({ data: ps || this.playerState })
    }
    this.onReady = () => {
      this.events.onReady && this.events.onReady({ target: this })
    }
    this.clearMocks = () => {
      [
        "getPlayerState",
        "isMuted",
        "mute",
        "unMute",
        "playVideo",
        "pauseVideo",
        "cueVideoById",
        "loadVideoById"
      ].forEach(k => this[k].mockClear());
    }

    this.destroy = () => {
      let idx
      while((idx = mocked.indexOf(this)) !== -1) {
        mocked.splice(idx, 1)
      }
    }

    mocked.push(this)

    return this
  }
}

Player.clearMocks = () => mocked.forEach(m => m.clearMocks());

export { Player }
