defmodule KsomniaWeb.SearchQuery do
  alias KsomniaWeb.SearchQuery
  alias Ecto.Changeset

  defstruct [:query]

  @types %{
    query: :string
  }

  def new(query) do
    {%SearchQuery{}, @types}
    |> Changeset.cast(%{query: query}, Map.keys(@types))
  end
end
