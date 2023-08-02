defmodule Ksomnia.AIHintTest do
  use Ksomnia.DataCase

  test "create ai_hint" do
    user = create_user!()
    team = create_team!(user)
    app = create_app!(team, user)

    error_identity = create_error_identity!(app)
    ai_hint = create_ai_hint!(error_identity, %{prompt: "test"})
    assert %AIHint{} = ai_hint

    ai_hint2 = create_ai_hint!(error_identity, %{prompt: "test"})
    assert ai_hint.prompt_hash == ai_hint2.prompt_hash

    ai_hint3 = create_ai_hint!(error_identity, %{prompt: "something else"})
    refute ai_hint.prompt_hash == ai_hint3.prompt_hash
  end
end
