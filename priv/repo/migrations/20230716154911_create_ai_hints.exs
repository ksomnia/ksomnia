defmodule Ksomnia.Repo.Migrations.CreateAiHints do
  use Ecto.Migration

  def change do
    create table(:ai_hints, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:provider, :string)
      add(:model, :string)
      add(:prompt, :text)
      add(:response, :text)
      add(:prompt_hash, :string)
      add(:error_identity_id, references(:error_identities, type: :uuid))

      timestamps()
    end

    create(index(:ai_hints, [:prompt_hash]))
  end
end
