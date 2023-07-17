defmodule Ksomnia.AIHint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ai_hints" do
    field :model, :string
    field :prompt, :string
    field :provder, :string

    timestamps()
  end

  @doc false
  def changeset(ai_hint, attrs) do
    ai_hint
    |> cast(attrs, [:provder, :model, :prompt])
    |> validate_required([:provder, :model, :prompt])
  end
end
