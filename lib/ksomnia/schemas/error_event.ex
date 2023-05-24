defmodule Ksomnia.Schemas.ErrorEvent do
  use Ecto.Schema
  alias Ksomnia.Schemas.ErrorEvent

  @primary_key false
  schema "error_events" do
    field :id, Ch, type: "UInt64"
    field :error_identity_id, Ch, type: "UUID"
    field :app_id, Ch, type: "UUID"
    field :timestamp, Ch, type: "DateTime64(3)"
    field :inserted_at, Ch, type: "DateTime64(3)"
    field :user_agent, Ch, type: "String"
    field :ip_address, Ch, type: "String"
    field :ipv4_address, Ch, type: "IPv4"
    field :ipv6_address, Ch, type: "IPv6"
  end

  def new(app, error_identity, params) do
    {:ok, error_identity_id} = ShortUUID.decode(error_identity.id)
    {:ok, app_id} = ShortUUID.decode(app.id)

    %ErrorEvent{
      id: Ksomnia.Security.random_uint64(),
      error_identity_id: error_identity_id,
      app_id: app_id,
      timestamp: params["timestamp"],
      inserted_at: NaiveDateTime.utc_now(),
      user_agent: params["user_agent"],
      ip_address: params["ip_address"],
      ipv4_address: params["ipv4_address"],
      ipv6_address: params["ipv6_address"]
    }
  end
end
