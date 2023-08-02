defmodule Ksomnia.AIHint.Prompt do
  def build(error_identity) do
    """
    The error message:

    #{error_identity.message}

    The error occurred in the file #{error_identity.source} at the line #{error_identity.line_number} and column #{error_identity.column_number}.

    The full stacktrace is:

    #{error_identity.stacktrace}
    """
  end

  def build_for_source_map(error_identity, [first_mapping | _] = mappings, sources) do
    """
    The error message:

    #{error_identity.message}

    The error occurred in the file `#{first_mapping.source}` at the line #{first_mapping.line} and column #{first_mapping.column}.

    The full stacktrace is:

    #{build_full_stacktrace(mappings)}

    The file content is delimited by ```:

    ```
    #{file_with_line_numbers(sources[first_mapping.source])}
    ```
    """
  end

  defp build_full_stacktrace(mappings) do
    Enum.map(mappings, fn mapping ->
      """
      #{mapping.source}:#{mapping.line}:#{mapping.column}
      """
    end)
  end

  def file_with_line_numbers(file_content) do
    file_content
    |> String.split(~r/\n/)
    |> Enum.with_index()
    |> Enum.map(fn {line, number} ->
      "#{number} #{line}"
    end)
    |> Enum.join("\n")
  end
end
