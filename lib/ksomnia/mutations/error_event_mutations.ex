defmodule Ksomnia.Mutations.ErrorEventMutations do
  alias Ksomnia.ErrorEvent
  alias Ksomnia.Util
  alias Ksomnia.ClickhouseRepo

  def create(app, error_identity, params) do
    error_event = ErrorEvent.new(app, error_identity, params)

    ClickhouseRepo.insert_all(ErrorEvent, Util.ecto_struct_to_map([error_event]))
  end
end
