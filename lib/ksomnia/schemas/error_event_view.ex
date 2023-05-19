defmodule Ksomnia.Schemas.ErrorEventView do
  use Ecto.Schema

  @primary_key false
  schema "error_events" do
    field :id, Ch, type: "UInt64"
    field :error_identity_id, Ch, type: "String"
    field :app_id, Ch, type: "String"
    field :timestamp, Ch, type: "DateTime64(3)"
    field :inserted_at, Ch, type: "DateTime64(3)"
    field :user_agent, Ch, type: "String"
    field :ip_address, Ch, type: "String"
    field :ipv4_address, Ch, type: "IPv4"
    field :ipv6_address, Ch, type: "IPv6"
  end
end
