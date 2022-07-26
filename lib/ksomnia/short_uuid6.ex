defmodule Ksomnia.ShortUUID6 do
  alias Ksomnia.UUID6

  @behaviour Ecto.Type

  def type, do: :uuid

  def cast(<<_::176>> = value), do: {:ok, value}
  def cast(_value), do: :error

  def load(<<_::128>> = value) do
    case ShortUUID.encode(value) do
      {:ok, short_uuid} -> {:ok, short_uuid}
      _ -> :error
    end
  end

  def load(_value), do: :error

  def dump(<<_::176>> = value) do
    case ShortUUID.decode(value) do
      {:ok, uuid} -> UUID6.dump(uuid)
      _ -> :error
    end
  end

  def dump(_value), do: :error

  def generate, do: ShortUUID.encode!(UUID6.generate())

  def autogenerate, do: generate()

  def equal?(value1, value2), do: UUID6.equal?(value1, value2)

  def embed_as(format), do: UUID6.embed_as(format)
end
