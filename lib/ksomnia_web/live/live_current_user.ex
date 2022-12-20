defmodule KsomniaWeb.LiveCurrentUser do
  alias Ksomnia.User
  alias Ksomnia.Repo
  use Phoenix.LiveComponent

  def on_mount(:current_user, _params, session, socket) do
    with user_id when is_binary(user_id) <- session["user_id"],
         %User{} = user <- Repo.get(User, user_id) do
      {:cont,
       socket
       |> assign(:current_user, user)
       |> assign(:user_apps_grouped, Ksomnia.App.for_user(user.id))
       |> assign(:__current_app__, nil)
       |> assign(:team, nil)}
    else
      _ ->
        {:cont, assign(socket, :current_user, nil)}
    end
  end

  def render(id), do: id
end
