defmodule Ksomnia.ErrorRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.ErrorRecord
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "error_records" do
    field :ip_address, :string
    field :user_agent, :string
    field :client_version, :string
    belongs_to :app, App, type: Ksomnia.ShortUUID6
    belongs_to :error_identity, App, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(error_record, attrs) do
    error_record
    |> cast(attrs, [:ip_address, :user_agent, :client_version])
    |> validate_required([:ip_address, :user_agent, :client_version])
  end

  def track(app, error_identity, params) do
    %ErrorRecord{app_id: app.id, error_identity_id: error_identity.id}
    |> changeset(%{
      ip_address: params["ip_address"],
      user_agent: params["user_agent"],
      client_version: params["client_version"],
      client_app_name: params["client_app_name"]
    })
    |> Repo.insert()
  end
end
