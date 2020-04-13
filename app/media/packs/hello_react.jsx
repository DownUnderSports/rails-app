// Run this example by adding "javascript_pack_tag 'hello_react'" to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'


const logEvent = (event) => {
  console.log(event)
  const { type, bubbles, cancelable, defaultPrevented, eventPhase } = event
  const html =  `
    <tr>
      <td>${type}</td>
      <td>${Date.now()}</td>
      <td>${JSON.stringify({ bubbles, cancelable, defaultPrevented, eventPhase})}</td>
    </tr>
  `
  document.getElementById("events").insertAdjacentHTML("beforeend", html)
}

document.addEventListener("DOMContentLoaded", logEvent)
document.addEventListener("turbolinks:load", logEvent)
document.addEventListener("turbolinks:visit", logEvent)
document.addEventListener("turbolinks:click", logEvent)
document.addEventListener("load", logEvent)

const Hello = props => (
  <div>Hello {props.name}!</div>
)

Hello.defaultProps = {
  name: 'David'
}

Hello.propTypes = {
  name: PropTypes.string
}

let loaded, mainContent, div

document.addEventListener('turbolinks:load', () => {
  mainContent = document.getElementById('main-content')
    || document.getElementsByTagName('main')[0]
  ReactDOM.render(
    <Hello name="React" />,
    mainContent.appendChild(div = document.createElement('div')),
  )
})
document.addEventListener('turbolinks:visit', () => {
  ReactDOM.unmountComponentAtNode(div)
  mainContent.removeChild(div)
})
