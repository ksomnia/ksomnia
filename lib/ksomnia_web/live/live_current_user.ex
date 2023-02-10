defmodule KsomniaWeb.LiveCurrentUser do
  alias Ksomnia.User
  alias Ksomnia.Repo
  alias Ksomnia.Queries.AppQueries
  use Phoenix.LiveComponent

  def on_mount(:current_user, _params, session, socket) do
    with user_id when is_binary(user_id) <- session["user_id"],
         %User{} = user <- Repo.get(User, user_id) do
      socket =
        socket
        |> assign(:current_user, user)
        |> assign(:user_apps_grouped, AppQueries.for_user(user.id))

      {:cont, socket}
    else
      _ ->
        {:cont, assign(socket, :current_user, nil)}
    end
  end

  def render(id), do: id
end
