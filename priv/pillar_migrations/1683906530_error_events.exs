defmodule Pillar.Migrations.ErrorEvents do
  def up do
    """
    CREATE TABLE error_events (
      id UInt64,
      error_identity_id UUID,
      app_id UUID,
      timestamp DateTime64(3),
      inserted_at DateTime64(3),
      user_agent String,
      ip_address String,
      ipv4_address IPv4,
      ipv6_address IPv6,
    ) ENGINE = MergeTree()
    ORDER BY (inserted_at, id);
    """
  end

  def down do
    "DROP TABLE error_events"
  end
end
