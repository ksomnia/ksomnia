defmodule Ksomnia.AppToken do
  use Ksomnia.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.User
  alias Ksomnia.AppToken
  alias Ksomnia.Util

  @type t() :: %AppToken{}

  schema "app_tokens" do
    field :token, :string
    field :revoked_at, :naive_datetime
    belongs_to :app, App
    belongs_to :user, User

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

  def put_token(changeset) do
    if changeset.data.token do
      changeset
    else
      put_change(changeset, :token, Ksomnia.Security.random_string(16))
    end
  end

  def put_revoked_at(app_token) do
    app_token
    |> change(revoked_at: Util.utc_now())
  end
end
