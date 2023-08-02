defmodule Ksomnia.AIHint do
  use Ksomnia.Schema
  import Ecto.Changeset
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.AIHint

  schema "ai_hints" do
    field(:prompt, :string)
    field(:model, :string)
    field(:provider, :string)
    field(:prompt_hash, :string)
    field(:response, :string)
    belongs_to(:error_identity, ErrorIdentity)

    timestamps()
  end

  @doc false
  def changeset(ai_hint, attrs) do
    ai_hint
    |> cast(attrs, [:provider, :model, :prompt, :response])
    |> validate_required([:provider, :model, :prompt])
    |> put_prompt_hash()
  end

  def new(error_identity, attrs) do
    changeset(%AIHint{error_identity_id: error_identity.id}, attrs)
  end

  def put_prompt_hash(changeset) do
    prompt = get_change(changeset, :prompt)

    if prompt == nil or String.trim(prompt) == "" do
      changeset
    else
      hash = Ksomnia.Security.hash_sha256(prompt)
      put_change(changeset, :prompt_hash, hash)
    end
  end
end
