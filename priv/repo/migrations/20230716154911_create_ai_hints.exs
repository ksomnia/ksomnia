defmodule Ksomnia.Repo.Migrations.CreateAiHints do
  use Ecto.Migration

  def change do
    create table(:ai_hints) do
      add :provder, :string
      add :model, :string
      add :prompt, :string

      timestamps()
    end
  end
end
