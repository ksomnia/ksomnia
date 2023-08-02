defmodule Ksomnia.Schemas.SourceMapper.Mapping do
  alias Ksomnia.Schemas.SourceMapper.Mapping

  # %{
  #   "column" => 13,
  #   "formattedLine" => "    return x['missing-key'](x)",
  #   "line" => 84,
  #   "name" => nil,
  #   "source" => "../../../assets/js/app.js"
  # },

  defstruct [:column, :formatted_line, :line, :source]

  def new(params) do
    %Mapping{
      column: params["column"],
      formatted_line: params["formattedLine"],
      line: params["line"],
      source: params["source"]
    }
  end
end
