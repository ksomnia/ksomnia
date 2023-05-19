defmodule Ksomnia.ErrorEventEmail do
  import Swoosh.Email
  alias Ksomnia.Queries.TeamQueries
  alias Ksomnia.Queries.UserQueries
  alias Ksomnia.Repo
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: KsomniaWeb.Endpoint,
    router: KsomniaWeb.Router

  def broadcast(app, error_identity) do
    team = TeamQueries.get_by_id(app.team_id)
    users = UserQueries.for_team(team) |> Repo.all()

    emails =
      if Application.get_env(:ksomnia, Ksomnia.Mailer)[:testing_email] do
        Application.get_env(:ksomnia, Ksomnia.Mailer)[:testing_email]
      else
        Enum.map(users, & &1.email)
      end

    error_notification(emails, app, error_identity)
  end

  def error_notification(emails, app, error_identity) do
    host = Application.get_env(:ksomnia, KsomniaWeb.Endpoint)[:url][:host]

    assigns = %{
      error_identity: error_identity,
      hash: Ksomnia.Util.commit_hash_abbriv(error_identity),
      app: app,
      host: host
    }

    html_body =
      Ksomnia.Mails.NewErrorView.render(assigns)
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    mail =
      new()
      |> to(emails)
      |> from({"Ksomnia", "noreply@#{host}"})
      |> subject("New error at #{app.name}: #{error_identity.message}")
      |> html_body(html_body)
      |> text_body(html_body)

    Ksomnia.Mailer.deliver(mail)
  end
end
