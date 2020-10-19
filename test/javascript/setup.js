import * as ActionCable from "@rails/actioncable"
import { WebSocket as MockWebSocket } from "mock-socket"
import { websocketUrl } from "./test-helpers/websocket-url"
ActionCable.adapters.WebSocket = MockWebSocket

const element = document.createElement("meta")
element.setAttribute("name", "action-cable-url")
element.setAttribute("content", websocketUrl)
document.head.appendChild(element)
