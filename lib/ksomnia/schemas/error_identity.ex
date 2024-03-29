defmodule Ksomnia.ErrorIdentity do
  use Ksomnia.Schema
  import Ecto.Changeset
  alias Ksomnia.App
  alias Ksomnia.ErrorIdentity

  @type t() :: %ErrorIdentity{}

  schema "error_identities" do
    field :error_identity_hash, :string
    field :source, :string
    field :line_number, :string
    field :column_number, :string
    field :message, :string
    field :stacktrace, :string
    field :commit_hash, :string
    field :track_count, :integer, default: 1
    field :last_error_at, :naive_datetime
    belongs_to :app, App

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
      :error_identity_hash,
      :commit_hash
    ])
    |> validate_required([
      :source,
      :line_number,
      :column_number,
      :message,
      :stacktrace,
      :last_error_at,
      :commit_hash
    ])
    |> put_error_identity_hash()
  end

  def put_error_identity_hash(changeset) do
    attrs = [
      :source,
      :line_number,
      :column_number,
      :message,
      :stacktrace,
      :commit_hash
    ]

    changes =
      attrs
      |> Enum.map(fn attr ->
        get_change(changeset, attr)
      end)
      |> Enum.filter(& &1)

    if Enum.empty?(changes) do
      changeset
    else
      hash = :crypto.hash(:sha256, changes) |> Base.url_encode64()
      put_change(changeset, :error_identity_hash, hash)
    end
  end
end
