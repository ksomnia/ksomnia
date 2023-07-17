defmodule Ksomnia.ErrorIdentityTest do
  use Ksomnia.DataCase

  describe "create/2" do
    test "creates error identites and updates track_count" do
      user = create_user!()
      team = create_team!(user)
      app = create_app!(team, user)

      {:ok, ie1} = create_error_identity(app)
      {:ok, ie2} = create_error_identity(app)

      assert ie1.track_count == 1
      assert ie2.track_count == 2
    end
  end
end
