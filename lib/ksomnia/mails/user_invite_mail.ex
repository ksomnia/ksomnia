defmodule Ksomnia.UserInviteEmail do
  import Swoosh.Email
  alias Ksomnia.Queries.UserQueries
  alias Ksomnia.Queries.TeamQueries
  alias Ksomnia.Team

  def pending_invite_notification(invite) do
    email = invite.email

    with %Team{} = team <- TeamQueries.get_by_id(invite.team_id),
         user <- UserQueries.get_by_email(email) do
      host = Application.get_env(:ksomnia, KsomniaWeb.Endpoint)[:url][:host]

      # TODO: Sign up with invite token

      html_body = """
      Hello#{user && " " <> user.username},
      You have been invited to #{team.name} at #{host}.
      """

      mail =
        new()
        |> to({email, email})
        |> from({"Ksomnia", "noreply@#{host}"})
        |> subject("You have a pending invitation to #{team.name}")
        |> html_body(html_body)
        |> text_body(html_body)

      {:ok, mail}
    end
  end
end
