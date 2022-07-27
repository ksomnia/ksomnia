defmodule KsomniaWeb.FallbackController do
  use Phoenix.Controller
  alias Ecto.Changeset

  def call(conn, {:error, _resource, %Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: format_changeset_errors(changeset)})
  end

  def call(conn, {:error, %Changeset{} = changeset, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: format_changeset_errors(changeset)})
  end

  def format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      "#{acc}#{k}: #{Enum.join(v, ", ")}. "
    end)
  end
end
