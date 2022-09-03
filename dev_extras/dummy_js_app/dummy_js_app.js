console.log('dummy_js_app.js', process.env.COMMIT_HASH)

window.onerror = function(message, source, lineNumber, columnNumber, error) {
  KSOMNIA.api('track', 'POST', {
    message: message,
    client_app_name: "dummy_js_app",
    client_version: "0.0.1",
    token: localStorage.getItem('dummy-js-app-token'),
    commit_hash: process.env.COMMIT_HASH,
    source: source || 'Script error',
    line_number: lineNumber ,
    column_number: columnNumber,
    stacktrace: (error && error.stack) || 'Script error'
  })
}

const BASE_URL = "/api/v1"

window.KSOMNIA = {}

KSOMNIA.api = (url, method, data) => {
  return fetch(`${BASE_URL}/${url}`, {
    method: method,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: JSON.stringify(data),
  })
}

document.addEventListener("DOMContentLoaded", () => {
  let appTokenInput = document.getElementById('app-token')
  appTokenInput.value = localStorage.getItem('dummy-js-app-token')
  appTokenInput.addEventListener('input', (e) => {
    localStorage.setItem('dummy-js-app-token', e.target.value)
  })

  let errorSampleBtn = document.getElementById('error-sample')
  errorSampleBtn.addEventListener('click', () => {
    JSON.parse('')
  })
})
