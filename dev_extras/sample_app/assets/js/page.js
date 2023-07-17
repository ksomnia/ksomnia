const init = () => {
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          token: document.getElementById('app-token').value,
          commit_hash: SAMPLE_APP_COMMIT_HASH
        })
      })
    })
  })
}

export default init
