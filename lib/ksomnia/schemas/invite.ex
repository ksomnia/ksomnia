defmodule Ksomnia.Invite do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.User
  alias Ksomnia.Util
  alias Ksomnia.Queries.UserQueries

  @type t() :: %Invite{}

  @primary_key {:id, Uniq.UUID, version: 4, autogenerate: true}
  schema "invites" do
    field :email, :string
    field :accepted_at, :naive_datetime
    belongs_to :team, Team, type: Uniq.UUID
    belongs_to :inviter, User, type: Uniq.UUID

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint([:email, :team_id], message: "has already been invited")
  end

  @spec new(binary(), binary(), map()) :: Ecto.Changeset.t()
  def new(team_id, inviter_id, attrs) do
    %Invite{team_id: team_id, inviter_id: inviter_id}
    |> changeset(attrs)
    |> ensure_not_member
  end

  @spec ensure_not_member(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def ensure_not_member(%{changes: %{email: email}} = changeset) do
    team_id = changeset.data.team_id

    if UserQueries.is_member?(email, team_id) do
      changeset
      |> add_error(:email, "the user is already a team member")
    else
      changeset
    end
  end

  def ensure_not_member(changeset), do: changeset

  def set_accepted_at(invite) do
    change(invite, accepted_at: Util.utc_now())
  end
end
