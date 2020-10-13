import { Consumer } from "channels/constants/consumer"
import { consumerConnectionTest } from "test-helpers/consumer-connection-test"

import {
  Consumer as ConsumerClass,
  Subscriptions as SubscriptionsClass
} from "@rails/actioncable"

describe("Channels", () => {
  describe("Constants", () => {
    describe("Consumer", () => {
      test("is an instance of actioncable Consumer", async () => {
        expect(Consumer).toBeInstanceOf(ConsumerClass)
      })

      test("manages subscriptions", async () => {
        expect(Consumer.subscriptions).toBeInstanceOf(SubscriptionsClass)
      })

      test("connects using websockets", async () => {
        await consumerConnectionTest(
          async ({ server, serverConnection }) => {
            Consumer.connect()
            const { clients } = await serverConnection
            expect(clients).toBeInstanceOf(Array)
            expect(clients.length).toBe(1)
          }
        )
      })

      test("disconnects using websockets", async () => {
        await consumerConnectionTest(
          async ({ server, serverConnection }) => {
            Consumer.connect()
            const { clients } = await serverConnection
            await new Promise(r => {
              clients[0].addEventListener("close", () => r())
              Consumer.disconnect()
            })
          }
        )
      })
    })
  })
})
