let hiddenKey, stateKey, changeKey;
if (typeof document.hidden !== "undefined") {
  hiddenKey = "hidden";
  changeKey = "visibilitychange";
  stateKey  = "visibilityState";
} else if (typeof document.mozHidden !== "undefined") {
  hiddenKey = "mozHidden";
  changeKey = "mozvisibilitychange";
  stateKey  = "mozVisibilityState";
} else if (typeof document.msHidden !== "undefined") {
  hiddenKey = "msHidden";
  changeKey = "msvisibilitychange";
  stateKey  = "msVisibilityState";
} else if (typeof document.webkitHidden !== "undefined") {
  hiddenKey = "webkitHidden";
  changeKey = "webkitvisibilitychange";
  stateKey  = "webkitVisibilityState";
} else if (typeof document.oHidden !== "undefined") {
  hiddenKey = "oHidden";
  changeKey = "ovisibilitychange";
  stateKey  = "oVisibilityState";
}
// else if('onfocusin' in document && 'hasFocus' in document) {
//   changeKey = "focusin focusout"
// } else {
//   changeKey = "focus blur"
// }

const listeners           = [],
      addEventListener    = (cb) => {
        if(cb) listeners.push(cb)
        else {
          try {
            throw new Error("callback undefined")
          } catch(e) {
            console.error(e)
          }
        }
      },
      removeEventListener = (cb) => {
        let idx
        while((idx = listeners.indexOf(cb)) !== -1) {
          listeners.splice(idx, 1)
        }
      }

export const visibility = {
  state: document[stateKey],
  hidden: document[hiddenKey],
  addEventListener,
  removeEventListener,
  hiddenKey,
  stateKey,
  changeKey
}

document.addEventListener(changeKey, () => {
  visibility.state = document[stateKey]
  visibility.hidden = document[hiddenKey]

  if(hiddenKey !== "hidden") {
    document.hidden = visibility.hidden
    document.visibilityState = visibility.state
  }
  listeners.forEach((cb) => cb(visibility.state));
}, false);
