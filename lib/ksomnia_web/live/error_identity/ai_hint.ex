defmodule KsomniaWeb.ErrorIdentityLive.AIHint do
  use KsomniaWeb, :live_view
  alias Ksomnia.Repo

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:stacktrace_type, "source_map")

    # |> assign(:mappings, [])
    # |> assign(:current_line, 0)
    # |> assign(:sources, nil)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = _params, _, socket) do
    error_identity = Ksomnia.Queries.ErrorIdentityQueries.get_by_id(id)
    error_identity = Repo.preload(error_identity, app: :team)
    app = error_identity.app
    team = error_identity.app.team

    ai_hint = """
    Based on the provided stacktrace, it seems that there is an error related to the 'missing-key' property of the 'x' object. Here are some possible solutions or hints to resolve the issue:

    1. Check if the 'missing-key' property exists in the 'x' object before accessing it. You can use the `hasOwnProperty` method to check if the property exists.

    Example:
    ```javascript
    const errorSample = (x) => {
      if (x.hasOwnProperty('missing-key')) {
        return x['missing-key'](x);
      }
      // Handle the case when the 'missing-key' property does not exist
      // e.g., throw an error, return a default value, or handle the case accordingly
    }
    ```

    2. Ensure that the 'missing-key' property is a function and can be invoked. If it's not a function, you may need to modify your code accordingly.

    3. Verify if the 'x' object is being passed correctly to the 'errorSample' function. Double-check the code that calls the `errorSample` function and ensure that the argument being passed has the necessary properties.

    4. Examine the stacktrace further and look for any additional error messages or line numbers that could provide more context on what might be causing the issue.
    """

    socket =
      socket
      |> assign(:page_title, error_identity.message)
      |> assign(:error_identity, error_identity)
      |> assign(:app, app)
      |> assign(:team, team)
      |> assign(:__current_app__, app.id)
      |> assign(:ai_hint, ai_hint)
      |> assign(:prompt, """
      The error message:
      Uncaught TypeError: Cannot read properties of undefined (reading 'missing-key')

      The error occurred in the file app.js at the line 84 and column 45.

      The file content:

      ```
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

      const BASE_URL = process.env.KSOMNIA_BASE_URL

      console.log({BASE_URL})

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
          return x['missing-key'](x)
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
      ```

      The full stacktrace is:

      84 return x['missing-key'](x) app.js
      88 return errorSample.apply(x) app.js
      100 errorWrapper('') app.js
      """)

    view_pid = self()

    # spawn(fn ->
    #   case SourceMapper.map_stacktrace(error_identity) do
    #     {:ok, %{"mappings" => mappings, "sources" => sources}} ->
    #       send(view_pid, %{mappings: mappings, sources: sources})

    #     _ ->
    #       nil
    #   end
    # end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(opts, socket) do
    {:noreply, assign(socket, opts)}
  end
end
