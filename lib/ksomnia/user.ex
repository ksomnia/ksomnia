defmodule Ksomnia.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.User

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :encrypted_password])
    |> validate_required([:email, :username, :encrypted_password])
  end

  def new(attrs) do
    %User{}
    |> changeset(attrs)
  end
end
