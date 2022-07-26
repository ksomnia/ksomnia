defmodule Ksomnia.UUID6 do
  use UUID.Ecto.Type,
    type: :uuid6,
    node_type: :random_bytes
end
