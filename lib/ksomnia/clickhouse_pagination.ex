defmodule Ksomnia.ClickhousePagination do
  import Ecto.Query
  alias Ksomnia.ClickhouseReadRepo
  alias Ksomnia.ClickhousePagination
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

    entry_count = ClickhouseReadRepo.aggregate(query, :count)
    total_pages = trunc(Float.ceil(entry_count / page_size))

    entries =
      query
      |> offset(^offset)
      |> limit(^page_size)
      |> ClickhouseReadRepo.all()

    current_page_size = length(entries)

    %ClickhousePagination{
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

    pagination =
      query
      |> ClickhousePagination.paginate(current_page)

    socket
    |> assign(:pagination, pagination)
  end

  def page_query_string(page) do
    %{}
    |> Ksomnia.Util.add_if("page", page)
    |> Enum.reduce("?", fn {k, v}, acc ->
      "#{acc}#{k}=#{v}&"
    end)
  end
end
