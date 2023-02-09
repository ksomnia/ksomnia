defmodule Ksomnia.UserInviteEmail do
  import Swoosh.Email
  alias Ksomnia.Queries.UserQueries
  alias Ksomnia.Team

  def pending_invite_notification(invite) do
    email = invite.email
    team = Team.get(invite.team_id)
    host = Application.get_env(:ksomnia, KsomniaWeb.Endpoint)[:url][:host]
    user = UserQueries.get(email: email)

    # TODO: Sign up with invite token

    html_body = """
    Hello#{user && " " <> user.username},
    You have been invited to #{team.name} at #{host}.
    """

    new()
    |> to({email, email})
    |> from({"Ksomnia", "noreply@#{host}"})
    |> subject("You have a pending invitation to #{team.name}")
    |> html_body(html_body)
    |> text_body(html_body)
  end
end
