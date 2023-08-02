defmodule Ksomnia.Rater do
  def check_rate(id, scale_ms, limit, func) do
    {_count, count_remaining, _ms_to_next_bucket, _created_at, _updated_at} =
      ExRated.inspect_bucket(id, scale_ms, limit)

    if count_remaining > 0 do
      ExRated.check_rate(id, scale_ms, limit)
      func.()
    else
      {:error, :rate_limit_exceeded}
    end
  end
end
