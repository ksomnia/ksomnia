defmodule Ksomnia.Invite do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Repo

  schema "invites" do
    field :email, :string
    field :accepted_at, :naive_datetime
    belongs_to :team, Team, type: Ksomnia.ShortUUID6
    belongs_to :inviter, User, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end

  def new(team_id, attrs) do
    %Invite{team_id: team_id}
    |> changeset(attrs)
  end

  def create(team_id, attrs) do
    new(team_id, attrs)
    |> Repo.insert()
  end
end
