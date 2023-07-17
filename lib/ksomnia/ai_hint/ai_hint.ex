defmodule Ksomnia.AIHint do
  @callback get_hint(context :: binary()) :: {:ok, hint :: binary()} | {:error, reason :: binary() }
end
