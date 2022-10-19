defmodule Ksomnia.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false
      add :username, :string
      add :encrypted_password, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
  end
end
