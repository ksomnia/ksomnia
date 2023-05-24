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
import Alpine from 'alpinejs'
import { drawChart } from './event_chart'

window.Alpine = Alpine

Alpine.start()

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.ChartHook = {
  mounted() {
    setTimeout(() => {
      (async function () {
        const chartEl = document.getElementById('error-identity-chart')
        if (chartEl) {
          const data = await getErrorIdentityChart(chartEl.getAttribute('data-id'))
          drawChart(chartEl, data)
        }

        const appChartEl = document.getElementById('app-chart')
        if (appChartEl) {
          const data = await getAppChart(appChartEl.getAttribute('data-id'))
          drawChart(appChartEl, data)
        }
      })()
    }, 100)
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken
  },
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#6366f1" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

const updateParams = ({ query }) => {
  let searchParams = new URLSearchParams(location.search)
  let page = searchParams.get('page') || 1
  let url = new URL(window.location)
  url.searchParams.set('page', page)
  url.searchParams.set('query', query)
  window.history.pushState(null, '', url.toString())
}

window.addEventListener("ksomnia:performSearchQuery", (event) => {
  let query = event.target.querySelector('#search_query_form_query').value
  updateParams({ query })
})

window.addEventListener("ksomnia:clearSearchInput", (event) => {
  event.target.value = ''
  updateParams({ query: '' })
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.KsomniaHelpers = {
  copyTokenHandle: (e) => {
    const token = document.getElementById('token').innerText
    navigator.clipboard.writeText(token)
  },

  logout: (e) => {
    let confirmLogout = confirm("Are you sure you want to log out?");
    if (confirmLogout) {
      window.location.assign('/logout');
    }
  }
}

const getErrorIdentityChart = async (id) => {
  const response = await fetch(`/api/v1/error_event_frequencies/error_identities/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  });

  const jsonPromise = response.json();
  const json = await jsonPromise;
  return json
}

const getAppChart = async (id) => {
  const response = await fetch(`/api/v1/error_event_frequencies/apps/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  });

  const jsonPromise = response.json();
  const json = await jsonPromise;
  return json
}

