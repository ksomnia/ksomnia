defmodule KsomniaWeb.LiveCurrentUser do
  alias Phoenix.LiveView
  alias Ksomnia.User
  alias Ksomnia.Repo

  def on_mount(:current_user, _params, session, socket) do
    with user_id when is_binary(user_id) <- session["user_id"],
         %User{} = user <- Repo.get(User, user_id) do
      {:cont,
       socket
       |> LiveView.assign(:current_user, user)
       |> LiveView.assign(:user_apps_grouped, Ksomnia.App.for_user(user.id))
       |> LiveView.assign(:open_modal, false)
       |> LiveView.assign(:team, nil)}
    else
      _ ->
        {:cont, LiveView.assign(socket, :current_user, nil)}
    end
  end
end
