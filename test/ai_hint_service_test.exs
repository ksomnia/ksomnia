defmodule Ksomnia.AIHintServiceTest do
  use Ksomnia.DataCase
  alias Ksomnia.AIHint.AIHintService

  test "ai_hint service test" do
    user = create_user!()
    team = create_team!(user)
    app = create_app!(team, user)

    error_identity = create_error_identity!(app)

    {:ok, ai_hint1} = AIHintService.get_or_create_hint_for_prompt(error_identity, "test prompt")
    {:ok, ai_hint2} = AIHintService.get_or_create_hint_for_prompt(error_identity, "test prompt")

    assert ai_hint1.id == ai_hint2.id
  end
end
