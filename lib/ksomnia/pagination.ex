defmodule Ksomnia.Pagination do
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.Pagination
  use Phoenix.Component

  @enforce_keys [
    :current_page_size,
    :entry_count,
    :total_pages,
    :entries,
    :current_page,
    :page_size,
    :surrounding_size
  ]
  defstruct [
    :current_page_size,
    :entry_count,
    :total_pages,
    :entries,
    :current_page,
    :page_size,
    :surrounding_size
  ]

  def paginate(query, current_page, page_size \\ 10, surrounding_size \\ 2) do
    offset = (current_page - 1) * page_size

    entry_count = Repo.aggregate(query, :count)
    total_pages = trunc(Float.ceil(entry_count / page_size))

    entries =
      query
      |> offset(^offset)
      |> limit(^page_size)
      |> Repo.all()

    current_page_size = length(entries)

    %Pagination{
      current_page: current_page,
      current_page_size: current_page_size,
      entry_count: entry_count,
      total_pages: total_pages,
      entries: entries,
      page_size: page_size,
      surrounding_size: surrounding_size
    }
  end

  def params_to_pagination(socket, query, params) do
    current_page = Map.get(params, "page", "1") |> String.to_integer()
    search_query = Map.get(params, "query", "") |> String.trim()

    pagination =
      query
      |> Pagination.paginate(current_page)

    socket
    |> assign(:pagination, pagination)
    |> Ksomnia.Util.assign_if(
      search_query != "",
      :search_query,
      KsomniaWeb.SearchQuery.new(search_query)
    )
  end

  def page_query_string(page, search_query) do
    %{}
    |> Ksomnia.Util.add_if("page", page)
    |> Ksomnia.Util.add_if("query", KsomniaWeb.SearchQuery.query(search_query))
    |> Enum.reduce("?", fn {k, v}, acc ->
      "#{acc}#{k}=#{v}&"
    end)
  end
end
