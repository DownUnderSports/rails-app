import * as ActionCable from "@rails/actioncable"
import { Server } from "mock-socket"
import { isFunction } from "test-helpers/is-function"
import { websocketUrl } from "./websocket-url"

export const consumerConnectionTest = (options, callback) => new Promise(async (r, j) => {
  if (options == null) options = {}
  else if (isFunction(options)) {
    callback = options
    options = {}
  }

  if(callback == null) callback = (data) => new Promise(r => r(data))

  const server = new Server(options.url || websocketUrl)
  let error
  try {
    const serverConnection = new Promise(async (resolve, reject) => {
      try {
        server.on("connection", function() {
          const clients = server.clients()
          expect(clients.length).toEqual(1)
          expect(clients[0].readyState).toBe(WebSocket.OPEN)
          resolve({ server, clients })
        })
      } catch(e) {
        reject(e)
      }
    })

    server.broadcastTo = function(subscription, data, callback) {
      if (data == null) { data = {} }
      data.identifier = subscription.identifier

      if (data.message_type) {
        data.type = ActionCable.INTERNAL.message_types[data.message_type]
        delete data.message_type
      }

      server.send(JSON.stringify(data))
      callback && setTimeout(callback, 1)
    }

    await callback({ server, serverConnection })
  } catch(e) {
    error = e
  } finally {
    try { server.close() } catch(e) { error = error || e }
  }
  if(error) j(error)
  else r()
})

export default consumerConnectionTest
