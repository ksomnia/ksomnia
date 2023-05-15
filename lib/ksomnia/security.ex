defmodule Ksomnia.Security do
  def random_string(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def random_uint64 do
    :crypto.strong_rand_bytes(8)
    |> :binary.decode_unsigned(:big)
  end
end
