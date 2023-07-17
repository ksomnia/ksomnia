defmodule Ksomnia.AIHint.ChatGPTHint do
  @behaviour Ksomnia.AIHintGetter

  def models(), do: @models

  def get_hint(prompt, opts) do
    model = Map.fetch!(opts, :model)

    OpenAI.chat_completion(
      model: to_string(model),
      messages: [
        %{
          role: "system",
          content:
            "You are a helping assistant who is helping find a solution for the bugs in JavaScript code."
        },
        %{
          role: "user",
          content: """
          #{prompt}
          """
        }
      ]
    )
  end

  def response_sample2() do
    """
    Based on the error message and the code, it seems that the error is occurring when the function `errorSample` is called on line 19. It is trying to access the property `'missing-key'` of an object, which is undefined.

    To fix this issue, you can add a check to see if the property `'missing-key'` exists before accessing it. If it doesn't exist, you can provide a default value or handle the error in a different way.

    Here is the suggested fix:

    ```diff
      const init = () => {
        const errorSample = (x) => {
    -     return x['missing-key'](x)
    +     return x['missing-key'] ? x['missing-key'](x) : "<default value/error handling>";
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
    ```

    This fix will check if `'missing-key'` exists in the object `x`. If it does, it will call the function with `x` as an argument. If it doesn't, you can provide a default value or handle the error in a different way.

    Please note that `"<default value/error handling>"` should be replaced with the appropriate code for your use case.
    """
  end
end
