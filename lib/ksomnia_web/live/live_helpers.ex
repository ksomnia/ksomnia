defmodule KsomniaWeb.LiveHelpers do
  @bg_gradients [
    "from-indigo-200 to-blue-200",
    "from-orange-200 to-red-200",
    "from-violet-200 to-purple-200",
    "from-pink-200 to-rose-200"
  ]

  def generate_gradient(string, reverse \\ false) do
    len = length(@bg_gradients)

    sum =
      string
      |> String.to_charlist()
      |> Enum.take(8)
      |> Enum.sum()

    gradient = Enum.at(@bg_gradients, rem(sum, len))

    if reverse do
      gradient |> String.split() |> Enum.reverse() |> Enum.join("")
    else
      gradient
    end
  end
end
