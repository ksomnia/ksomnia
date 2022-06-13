defmodule Ksomnia.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.User

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string
    field :password, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> encrypt_password()
  end

  def encrypt_password(changeset) do
    changeset
  end

  def new(attrs) do
    %User{}
    |> changeset(attrs)
  end

  def create(attrs) do
    new(attrs)
    |> Repo.insert()
  end
end
