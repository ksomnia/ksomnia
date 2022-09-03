defmodule Ksomnia.ErrorIdentity do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.ErrorIdentity
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "error_identities" do
    field :source, :string
    field :line_number, :string
    field :column_number, :string
    field :message, :string
    field :stacktrace, :string
    field :commit_hash, :string
    field :track_count, :integer, default: 1
    field :last_error_at, :naive_datetime
    belongs_to :app, App, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(error_record, attrs) do
    error_record
    |> cast(attrs, [
      :source,
      :line_number,
      :column_number,
      :message,
      :stacktrace,
      :last_error_at,
      :commit_hash
    ])
    |> validate_required([
      :source,
      :line_number,
      :column_number,
      :message,
      :stacktrace,
      :last_error_at
    ])
  end

  def create(app, params) do
    %ErrorIdentity{app_id: app.id}
    |> changeset(Map.merge(params, %{"last_error_at" => NaiveDateTime.utc_now()}))
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
        :source,
        :line_number,
        :column_number,
        :message,
        :stacktrace
      ],
      returning: true
    )
  end

  def for_app(app) do
    from(er in ErrorIdentity, where: er.app_id == ^app.id, order_by: [desc: er.last_error_at])
    |> Repo.all()
  end
end
