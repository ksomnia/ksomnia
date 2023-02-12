defmodule Ksomnia.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.User
  alias Ksomnia.TeamUser

  @type t() :: %User{}
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true
    field :role, :string, virtual: true
    field :avatar_original_path, :string
    field :avatar_resized_paths, :map, default: %{}
    has_many :team_users, TeamUser

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password, :avatar_original_path, :avatar_resized_paths])
    |> validate_required([:email, :username, :password])
    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> update_change(:username, &String.trim/1)
    |> encrypt_password()
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def change_password_changeset(user, params) do
    user
    |> new_password_changeset(params)
    |> validate_change(:current_password, fn :current_password, current_password ->
      unless Argon2.verify_pass(current_password, user.encrypted_password) do
        [current_password: "Invalid current password"]
      else
        []
      end
    end)
    |> encrypt_password()
  end

  def new_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:current_password, :password, :password_confirmation])
    |> validate_required([:current_password, :password, :password_confirmation])
    |> validate_confirmation(:password)
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password, :avatar_original_path, :avatar_resized_paths])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def encrypt_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      put_change(changeset, :encrypted_password, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end

  def new(attrs) do
    %User{}
    |> changeset(attrs)
  end
end
