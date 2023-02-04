defmodule Ksomnia.AppToken do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.User
  alias Ksomnia.AppToken
  alias Ksomnia.Repo

  schema "app_tokens" do
    field :token, :string
    field :revoked_at, :naive_datetime
    belongs_to :app, App, type: Ecto.ShortUUID
    belongs_to :user, User, type: Ecto.ShortUUID

    timestamps()
  end

  @doc false
  def changeset(app, _) do
    app
    |> cast(%{}, [])
    |> put_token()
  end

  def new(app_id, user_id) do
    %AppToken{app_id: app_id, user_id: user_id}
    |> changeset(%{})
  end

  def create(app_id, user_id) do
    new(app_id, user_id)
    |> Repo.insert()
  end

  def put_token(changeset) do
    if changeset.data.token do
      changeset
    else
      put_change(changeset, :token, Ksomnia.Security.random_string(16))
    end
  end

  def revoke(app_token) do
    app_token
    |> change(revoked_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second))
    |> Repo.update()
  end

  def all(app_id) do
    from(a in AppToken,
      join: u in assoc(a, :user),
      where: a.app_id == ^app_id,
      order_by: [asc: not is_nil(a.revoked_at), desc: :inserted_at],
      preload: [:user]
    )
  end
end
