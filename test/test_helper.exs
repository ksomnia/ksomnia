ExUnit.start()
{:ok, _} = Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.Sandbox.mode(Ksomnia.Repo, :manual)
Faker.start()
