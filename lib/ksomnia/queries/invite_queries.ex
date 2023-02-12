defmodule Ksomnia.Queries.InviteQueries do
  import Ecto.Query
  alias Ksomnia.Invite
  alias Ksomnia.Team
  alias Ksomnia.Repo

  @spec search_by_email(Ecto.Query.t(), binary()) :: Ecto.Query.t()
  def search_by_email(query, ""), do: query

  def search_by_email(query, search_query) do
    from(u in query,
      where: ilike(u.email, ^"%#{search_query}%")
    )
  end

  @spec pending_for_team(Team.t()) :: Ecto.Query.t()
  def pending_for_team(team) do
    from(i in Invite, where: i.team_id == ^team.id and is_nil(i.accepted_at))
  end

  @spec for_user_email(binary()) :: [Invite.t()]
  def for_user_email(email) do
    from(i in Invite, where: i.email == ^email and is_nil(i.accepted_at), preload: [:team])
    |> Repo.all()
  end

  @spec get_by_id(binary()) :: Invite.t() | nil
  def get_by_id(invite_id) do
    Repo.get(Invite, invite_id)
  end

  @spec get_by_email_and_team_id(binary(), binary()) :: Invite.t() | nil
  def get_by_email_and_team_id(email, team_id) do
    Repo.get_by(Invite, email: email, team_id: team_id)
  end
end
