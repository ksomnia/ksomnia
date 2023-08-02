defmodule Ksomnia.UserApp do
  use Ksomnia.Schema
  import Ecto.Changeset
  alias Ksomnia.User
  alias Ksomnia.App
  alias Ksomnia.UserApp

  @type t() :: %UserApp{}

  schema "user_apps" do
    belongs_to :user, User
    belongs_to :app, App

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
