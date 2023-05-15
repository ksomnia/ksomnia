defmodule Ksomnia.UserApp do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.User
  alias Ksomnia.App
  alias Ksomnia.UserApp

  @type t() :: %UserApp{}

  @primary_key {:id, Uniq.UUID, version: 4, autogenerate: true}
  schema "user_apps" do
    belongs_to :user, User, type: Uniq.UUID
    belongs_to :app, App, type: Uniq.UUID

    timestamps()
  end

  @doc false
  def changeset(user_app, attrs \\ %{}) do
    user_app
    |> cast(attrs, [])
  end

  def new(user_id, app_id) do
    %UserApp{user_id: user_id, app_id: app_id}
    |> changeset(%{})
  end
end
