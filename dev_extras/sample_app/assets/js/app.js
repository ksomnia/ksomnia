// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

const commitHash = process.env.COMMIT_HASH

console.log('Commit hash', commitHash)

window.onerror = function (message, source, lineNumber, columnNumber, error) {
  KSOMNIA.api('track', 'POST', {
    message: message,
    client_app_name: 'ksomnia_sample_app',
    client_version: "0.0.1",
    token: localStorage.getItem('ksomnia-sample-app-token'),
    commit_hash: process.env.COMMIT_HASH,
    source: source || 'Script error',
    line_number: lineNumber,
    column_number: columnNumber,
    stacktrace: (error && error.stack) || 'Script error'
  })
}

const BASE_URL = "http://localhost:4000/tracker_api/v1"

window.KSOMNIA = {}

const JSONHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}

KSOMNIA.api = (url, method, data) => {
  return fetch(`${BASE_URL}/${url}`, {
    method: method,
    headers: JSONHeaders,
    body: JSON.stringify(data),
  })
}

const nested = () => {
  const errorSample = (x) => {
    return x['key'](x)
  }

  const errorWrapper = (...x) => {
    return errorSample.apply(x)
  }

  document.addEventListener("DOMContentLoaded", () => {
    let appTokenInput = document.getElementById('app-token')
    appTokenInput.value = localStorage.getItem('ksomnia-sample-app-token')
    appTokenInput.addEventListener('input', (e) => {
      localStorage.setItem('ksomnia-sample-app-token', e.target.value)
    })

    let errorSampleBtn = document.getElementById('error-sample-btn')
    errorSampleBtn.addEventListener('click', () => {
      errorWrapper('')
    })

    document.getElementById('deploy-btn').addEventListener('click', () => {
      console.log('deploy', document.getElementById('app-token').value)

      fetch(`/api/deploy`, {
        method: 'POST',
        headers: JSONHeaders,
        body: JSON.stringify({
          token: document.getElementById('app-token').value,
          commit_hash: commitHash
        })
      })
    })
  })
}

nested()
