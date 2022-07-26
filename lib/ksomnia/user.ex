defmodule Ksomnia.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.Repo
  alias Ksomnia.User

  # @primary_key {:id, Ecto.ShortUUID, autogenerate: true}
  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username, :password])
    |> encrypt_password()
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def encrypt_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :encrypted_password, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
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
