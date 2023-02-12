defmodule Ksomnia.Mutations.InviteMutations do
  alias Ksomnia.Invite
  alias Ksomnia.TeamUser
  alias Ksomnia.User
  alias Ksomnia.Queries.InviteQueries
  alias Ksomnia.Repo

  @spec create(binary(), binary(), map()) :: {:ok, Invite.t()} | {:error, any()}
  def create(team_id, inviter_id, attrs) do
    with {:ok, invite} <- Repo.insert(Invite.new(team_id, inviter_id, attrs)),
         {:ok, %Swoosh.Email{} = email} <-
           Ksomnia.UserInviteEmail.pending_invite_notification(invite) do
      Ksomnia.Mailer.deliver(email)
      {:ok, invite}
    end
  end

  @spec revoke(Invite.t()) :: {:ok, Invite.t()} | {:error, any()}
  def revoke(invite) do
    Repo.delete(invite)
  end

  @spec reject(binary(), User.t()) :: {:ok, Invite.t()} | {:error, any()}
  def reject(invite_id, invitee) do
    with %Invite{} = invite <- InviteQueries.get_by_id(invite_id),
         true <- invite.email == invitee.email do
      Repo.delete(invite)
    else
      _ -> :error
    end
  end

  @spec accept(binary(), User.t()) ::
          {:ok, %{invite: Invite.t(), team_user: TeamUser.t()}}
          | {:error, term(), Ecto.Changeset.t(), any()}
  def accept(invite_id, invitee) when is_binary(invite_id) do
    with %Invite{} = invite <- InviteQueries.get_by_id(invite_id),
         {:ok, _} = result <- do_accept(invite, invitee) do
      result
    end
  end

  defp do_accept(%Invite{} = invite, %User{} = invitee) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:invite, Invite.set_accepted_at(invite))
    |> Ecto.Multi.insert(:team_user, fn %{} ->
      TeamUser.new(invite.team_id, invitee.id, %{role: "member"})
    end)
    |> Repo.transaction()
  end

  @spec delete_if_exists(binary(), binary()) :: {:ok, Invite.t()} | {:error, any()}
  def delete_if_exists(email, team_id) do
    with %Invite{} = invite <- InviteQueries.get_by_email_and_team_id(email, team_id) do
      Repo.delete(invite)
    end
  end
end
