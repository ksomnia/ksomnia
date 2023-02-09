defmodule Ksomnia.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Ksomnia.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ksomnia.App
      alias Ksomnia.Repo
      alias Ksomnia.User
      alias Ksomnia.Team
      alias Ksomnia.TeamUser
      alias Ksomnia.Invite
      alias Ksomnia.ErrorIdentity
      use Ksomnia.QueryHelper

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Ksomnia.DataCase
      import Ksomnia.Factory

      def create_user() do
        User.create(%{
          "email" => Faker.Internet.email(),
          "username" => Faker.Internet.user_name(),
          "password" => "password"
        })
      end

      def create_user!() do
        {:ok, user} = create_user()
        user
      end

      def create_team(user) do
        Team.create(user, %{
          "name" => Faker.Company.name()
        })
      end

      def create_team!(user) do
        {:ok, %{team: team}} = create_team(user)
        team
      end

      def create_app(team, user) do
        App.create(team.id, user.id, %{
          name: Faker.App.name()
        })
        |> case do
          {:ok, %{app: app}} ->
            {:ok, app}

          error ->
            error
        end
      end

      def create_app!(team, user) do
        {:ok, app} = create_app(team, user)
        app
      end
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Ksomnia.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
