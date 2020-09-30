import { Consumer } from "channels/constants/consumer"
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
    })
  })
})
