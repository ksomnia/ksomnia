defmodule Ksomnia.Pagination do
  import Ecto.Query
  alias Ksomnia.Repo

  def paginate(query, current_page, page_size) do
    current_page = current_page - 1
    offset = current_page * page_size

    entry_count = Repo.aggregate(query, :count)
    total_pages = trunc(Float.ceil(entry_count / page_size))

    entries =
      query
      |> offset(^offset)
      |> limit(^page_size)
      |> Repo.all()

    %{
      current_page_size: length(entries),
      entry_count: entry_count,
      total_pages: total_pages,
      entries: entries
    }
  end
end
