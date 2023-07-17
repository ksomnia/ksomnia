defmodule Ksomnia.AIHint.ChatGPTHint do
  @behaviour Ksomnia.AIHint

  def get_hint(context) do
    OpenAI.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [
        %{
          role: "system",
          content:
            "You are a helping assistant who is helping find a solution for the bugs in JavaScript code."
        },
        %{
          role: "user",
          content: """
          #{context}
          """
        }
      ]
    )
  end
end
