defmodule KsomniaWeb.LiveHelpers do
  def user_avatar(user) do
    user.username
    |> String.first()
    |> String.capitalize()
  end

  @bg_gradients [
    "from-indigo-200 to-blue-200",
    "from-orange-200 to-red-200",
    "from-violet-200 to-purple-200",
    "from-pink-200 to-rose-200"
  ]

  def generate_gradient(string) do
    len = length(@bg_gradients)

    sum =
      string
      |> String.to_charlist()
      |> Enum.take(8)
      |> Enum.sum()

    Enum.at(@bg_gradients, rem(sum, len))
  end
end
