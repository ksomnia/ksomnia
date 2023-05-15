defmodule Ksomnia.ClickhouseRepo do
  use Ecto.Repo,
    otp_app: :ksomnia,
    adapter: Ecto.Adapters.ClickHouse
end
