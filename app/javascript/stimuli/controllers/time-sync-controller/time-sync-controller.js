import { Controller } from "stimuli/constants/controller"
import { format } from "date-fns-tz"
import { importTZPolyfill } from "./import-tz-polyfill"

export class TimeSyncController extends Controller {
  static keyName = "time-sync"
  static targets = [ "date" ]
  async connected() {
    await importTZPolyfill()

    this.setValues()
  }

  setValues = () => {
    const changes = []

    this.dateTargets.forEach(target => {
      const formatValue = target.getAttribute("data-unicode-format")

      if(formatValue) {
        const utcValue = +(target.getAttribute("data-utc") || 0),
              utcDate = new Date(0)

        utcDate.setUTCMilliseconds(utcValue)
        changes.push([target, format(utcDate, formatValue)])
      }
    });

    changes.forEach(([ target, value ]) => target.innerHTML = value);
  }
}
