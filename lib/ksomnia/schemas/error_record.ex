defmodule Ksomnia.ErrorRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.ErrorRecord
  alias Ksomnia.Repo

  @type t() :: %ErrorRecord{}

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  schema "error_records" do
    field :ip_address, :string
    field :user_agent, :string
    field :client_version, :string
    belongs_to :app, App, type: Uniq.UUID
    belongs_to :error_identity, App, type: Uniq.UUID

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
