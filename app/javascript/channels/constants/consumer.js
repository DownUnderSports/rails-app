// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

const uninitialized = !window._ActionCableConsumer

if(uninitialized) window._ActionCableConsumer = createConsumer()

export const Consumer = window._ActionCableConsumer
