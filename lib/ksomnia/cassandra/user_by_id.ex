defmodule Ksomnia.UserById do
  use Cassandrax.Schema

  @primary_key [:id]

  table "user_by_id" do
    field :id, Ecto.UUID
    field :email, :string
    field :username, :string
    # field :encrypted_password, :string, default: nil
    # field :avatar_original_path, :string, default: nil
    # field :avatar_resized_paths, :map, default: %{}
  end
end
