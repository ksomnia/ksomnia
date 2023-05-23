defmodule Ksomnia.Queries.ErrorEventQueries do
  import Ecto.Query
  alias Ksomnia.Schemas.ErrorEventView
  alias Ksomnia.ClickhouseReadRepo

  def for_error_identity(error_identity) do
    {:ok, error_identity_id} = ShortUUID.decode(error_identity.id)

    from(e in ErrorEventView,
      where: e.error_identity_id == ^error_identity_id,
      order_by: [desc: e.inserted_at]
    )
  end

  def app_frequencies(app) do
    {:ok, app_id} = ShortUUID.decode(app.id)

    sql = """
      SELECT
        toStartOfInterval(inserted_at, INTERVAL 1 HOUR) AS hour,
        count(id)
      FROM error_events
      WHERE inserted_at >= now() - INTERVAL 24 HOUR AND app_id = '#{app_id}'
      GROUP BY hour
      ORDER BY hour ASC WITH FILL FROM now() - INTERVAL 24 HOUR TO now() STEP toIntervalHour(1)
    """

    Ecto.Adapters.SQL.query!(ClickhouseReadRepo, sql, [])
    |> normalize_result()
  end

  def error_identity_frequencies(error_identity) do
    {:ok, error_identity_id} = ShortUUID.decode(error_identity.id)

    sql = """
      SELECT
        toStartOfInterval(inserted_at, INTERVAL 1 HOUR) AS hour,
        count(id)
      FROM error_events
      WHERE inserted_at >= now() - INTERVAL 24 HOUR AND error_identity_id = '#{error_identity_id}'
      GROUP BY hour
      ORDER BY hour ASC WITH FILL FROM now() - INTERVAL 24 HOUR TO now() STEP toIntervalHour(1)
    """

    Ecto.Adapters.SQL.query!(ClickhouseReadRepo, sql, [])
    |> normalize_result()
  end

  def normalize_result(%Ch.Result{rows: rows}) do
    Enum.map(rows, fn [hour, count] ->
      %{hour: hour, count: count}
    end)
  end
end
