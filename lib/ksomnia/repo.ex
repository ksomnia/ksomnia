defmodule Ksomnia.Repo do
  use Ecto.Repo,
    otp_app: :ksomnia,
    adapter: Ecto.Adapters.Postgres
end
