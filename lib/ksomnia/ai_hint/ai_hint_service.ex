defmodule Ksomnia.AIHint.AIHintService do
  alias Ksomnia.AIHint.AIHintConfig
  require Logger

  def get_or_create_hint_for_prompt(error_identity, prompt) do
    ai_hint = Ksomnia.Queries.AIHintQueries.latest_for_prompt(error_identity.id, prompt)

    if ai_hint do
      {:ok, ai_hint}
    else
      %AIHintConfig{} = ai_hint_provider = ai_hint_provider()
      model = ai_hint_provider.default_model
      provider = ai_hint_provider.provider
      args = [prompt, %{model: model}]
      reply = apply(provider, :get_hint, args)

      case reply do
        {:ok, response} ->
          Ksomnia.Mutations.AIHintMutations.create(error_identity, %{
            prompt: prompt,
            provider: provider |> to_string,
            model: model,
            response: response
          })

        error ->
          Logger.error("Error: #{inspect(error)}")
          {:error, "Could not get the hint"}
      end
    end
  end

  @spec ai_hint_provider() :: AIHintConfig.t()
  def ai_hint_provider do
    map = Application.get_env(:ksomnia, :ai_hint)
    struct(AIHintConfig, map)
  end
end
