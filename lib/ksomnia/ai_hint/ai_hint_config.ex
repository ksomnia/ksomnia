defmodule Ksomnia.AIHint.AIHintConfig do
  defstruct [:provider, :models, :default_model]

  @type t :: %__MODULE__{
          provider: String.t(),
          models: list(String.t()),
          default_model: String.t()
        }
end
