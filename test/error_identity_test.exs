defmodule Ksomnia.ErrorIdentityTest do
  use Ksomnia.DataCase

  describe "create/2" do
    test "creates error identites and updates track_count" do
      user = create_user!()
      team = create_team!(user)
      app = create_app!(team)

      {:ok, ie1} = create_error_identity(app)
      {:ok, ie2} = create_error_identity(app)

      assert ie1.track_count == 1
      assert ie2.track_count == 2
    end
  end

  def create_error_identity(app) do
    stacktrace = """
    TypeError: Cannot read properties of undefined (reading 'missing-key')
    |     at Array.e (http://localhost:5500/assets/app.js:17:15006)
    |     at t (http://localhost:5500/assets/app.js:17:15037)
    |     at HTMLButtonElement.<anonymous> (http://localhost:5500/assets/app.js:17:15367)
    """

    ErrorIdentity.create(app, %{
      "source" => "http://localhost:5500/assets/app.js",
      "message" =>
        "Uncaught TypeError: Cannot read properties of undefined (reading 'missing-key')",
      "stacktrace" => stacktrace,
      "line_number" => "17",
      "column_number" => "15006",
      "last_error_at" => NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
      "commit_hash" => "4507f5025dc80afd8492fc78a4ddd30aae3e0c2a"
    })
  end
end
