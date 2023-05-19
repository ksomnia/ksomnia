defmodule Ksomnia.ClickhouseReadRepo do
  use Ecto.Repo,
    otp_app: :ksomnia,
    adapter: Ecto.Adapters.ClickHouse,
    read_only: true
end
