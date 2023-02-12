defmodule Ksomnia.Mutations.UserMutations do
  alias Ksomnia.Repo
  alias Ksomnia.User

  @spec create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    User.new(attrs)
    |> Repo.insert()
  end

  @spec update_profile(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @spec change_password(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_password(user, params) do
    user
    |> User.change_password_changeset(params)
    |> Repo.update()
  end
end
