defmodule Ksomnia.QueryHelper do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ksomnia.Queries.UserQueries
      alias Ksomnia.Repo

      def count_for_query(query) do
        Repo.count(query)
      end
    end
  end
end
