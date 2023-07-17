defmodule Ksomnia.AIHintGetter do
  @callback get_hint(prompt :: binary(), opts :: map()) ::
              {:ok, hint :: binary()} | {:error, reason :: binary()}
end
