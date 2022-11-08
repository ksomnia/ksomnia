defmodule Ksomnia.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.User
  alias Ksomnia.TeamUser
  use Ksomnia.DataHelper, [:get, User]

  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true
    field :role, :string, virtual: true
    has_many :team_users, TeamUser

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

  def change_password(user, params) do
    if Argon2.verify_pass(params["current_password"], user.encrypted_password) do
      user
      |> new_password_changeset(params)
      |> Repo.update()
    else
      changeset =
        user
        |> new_password_changeset(params)
        |> add_error(:current_password, "invalid", validation: :required)

      {:error, changeset}
    end
  end

  def new_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:current_password, :password, :password_confirmation])
    |> validate_required([:current_password, :password, :password_confirmation])
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
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

  def create(attrs) do
    new(attrs)
    |> Repo.insert()
  end

  def update_profile(user, attrs) do
    user
    |> profile_changeset(attrs)
    |> Repo.update()
  end

  def for_team(team) do
    from(u in User,
      join: tu in assoc(u, :team_users),
      where: tu.team_id == ^team.id,
      select: %{
        u
        | role: tu.role
      }
    )
    |> Repo.all()
  end
end
