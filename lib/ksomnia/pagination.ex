defmodule Ksomnia.Pagination do
  import Ecto.Query
  alias Ksomnia.Repo
  alias Ksomnia.Pagination

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

    %Pagination{
      current_page: current_page,
      current_page_size: length(entries),
      entry_count: entry_count,
      total_pages: total_pages,
      entries: entries,
      page_size: page_size,
      surrounding_size: surrounding_size
    }
  end
end
