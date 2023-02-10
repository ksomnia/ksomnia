defmodule Ksomnia.UserApp do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.User
  alias Ksomnia.App
  alias Ksomnia.UserApp
  use Ksomnia.DataHelper, [:get, UserApp]

  @type t() :: %UserApp{}
  @primary_key {:id, Ecto.ShortUUID, autogenerate: true}

  schema "user_apps" do
    belongs_to :user, User, type: Ecto.ShortUUID
    belongs_to :app, App, type: Ecto.ShortUUID

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
