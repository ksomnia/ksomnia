defmodule KsomniaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use KsomniaWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Ksomnia.Fixtures
      alias Ksomnia.User

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import KsomniaWeb.ConnCase

      alias KsomniaWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint KsomniaWeb.Endpoint

      use KsomniaWeb, :verified_routes

      def login_as(conn, %User{} = user) do
        Plug.Test.init_test_session(conn, user_id: user.id)
      end
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Ksomnia.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
