defmodule KsomniaWeb.AsyncChain do
  def start(socket, mod, fns) do
    spawn_chain(socket, mod, self(), fns)
    socket
  end

  def spawn_chain(socket, mod, view_pid, [elem | rest]) do
    spawn(fn ->
      case apply(mod, elem, [socket]) do
        {:ok, assigns} ->
          send(view_pid, assigns)

        _ ->
          nil
      end

      spawn_chain(socket, mod, view_pid, rest)
    end)
  end

  def spawn_chain(socket, _, _, []) do
    socket
  end
end
