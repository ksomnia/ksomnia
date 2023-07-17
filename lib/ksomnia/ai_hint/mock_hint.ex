defmodule Ksomnia.AIHint.MockHint do
  @behaviour Ksomnia.AIHintGetter

  def get_hint(prompt, opts) do
    model = Map.fetch!(opts, :model)

    reply = """
    Mocked reply to #{prompt} using #{model}.
    """

    {:ok, reply}
  end
end
