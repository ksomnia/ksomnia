defmodule Ksomnia.AIHint.ChatGPTHint do
  @behaviour Ksomnia.AIHintGetter
  require Logger

  def get_hint(prompt, opts) do
    model = Map.fetch!(opts, :model)

    Ksomnia.Rater.check_rate model, :timer.seconds(10), 5 do
      get_completion(model, prompt)
    end
  end

  def get_completion(model, prompt) do
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
    |> get_first_choice()
  end

  defp get_first_choice({:ok, %{choices: [%{"message" => %{"content" => content}} | _]}}) do
    {:ok, content}
  end

  defp get_first_choice(error) do
    Logger.error("#{__MODULE__} Error parsing response: #{inspect(error)}")
    {:error, "Error getting first choice"}
  end
end
