defmodule KsomniaWeb.LiveCurrentUser do
  alias Phoenix.LiveView
  alias Ksomnia.User
  alias Ksomnia.Repo

  def on_mount(:current_user, _params, session, socket) do
    with user_id when is_binary(user_id) <- session["user_id"],
         %User{} = user <- Repo.get(User, user_id) do
      {:cont, LiveView.assign(socket, :current_user, user)}
    else
      _ ->
        {:cont, LiveView.assign(socket, :current_user, nil)}
    end
  end
end
