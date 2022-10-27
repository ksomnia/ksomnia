defmodule Ksomnia.DataHelper do
  def get(module) do
    quote do
      alias Ksomnia.Repo

      def get(id) when is_binary(id), do: Repo.get(unquote(module), id)

      def get(fields) do
        Repo.get_by(unquote(module), fields)
      end
    end
  end

  defmacro __using__([which, mod]) when is_atom(which) do
    apply(__MODULE__, which, [mod])
  end
end
