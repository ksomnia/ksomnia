defmodule Ksomnia.Mutations.ErrorIdentityMutations do
  alias Ksomnia.Repo
  alias Ksomnia.ErrorIdentity

  def create(app, params) do
    %ErrorIdentity{app_id: app.id}
    |> ErrorIdentity.changeset(Map.merge(params, %{"last_error_at" => NaiveDateTime.utc_now()}))
    |> Repo.insert(
      on_conflict: [
        set: [
          last_error_at: NaiveDateTime.utc_now()
        ],
        inc: [
          track_count: 1
        ]
      ],
      conflict_target: [
        :error_identity_hash
      ],
      returning: true
    )
  end
end
