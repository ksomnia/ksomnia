defmodule Ksomnia.AIHint.MockHint do
  @behaviour Ksomnia.AIHintGetter

  def get_hint(_prompt, opts) do
    model = Map.fetch!(opts, :model)

    reply = """
    Mocked reply using #{model}.
    """

    :timer.sleep(:timer.seconds(Enum.random(1..3)))

    {:ok, reply}
  end
end
