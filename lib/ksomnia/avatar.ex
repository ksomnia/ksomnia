defmodule Ksomnia.Avatar do
  use KsomniaWeb, :html

  @resource_types ["apps"]

  def consume(socket, params, resource_type, resource) when resource_type in @resource_types do
    Phoenix.LiveView.consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      {:ok, resize_and_save(resource_type, resource, path)}
    end)
    |> case do
      [uploaded_file] ->
        Map.merge(params, %{
          "avatar_original_path" => uploaded_file.avatar_original_path,
          "avatar_resized_paths" => uploaded_file.avatar_resized_paths
        })

      _ ->
        params
    end
  end

  def resize_and_save(resource_type, resource, path) when resource_type in @resource_types do
    base = [
      :code.priv_dir(:ksomnia),
      "static",
      "uploads",
      "avatars",
      resource_type,
      resource.id
    ]

    dest = Path.join(base ++ [Path.basename(path), Path.extname(path)])
    File.mkdir_p!(Path.join(base))
    File.cp!(path, dest)

    dest_160x160 = Path.join(base ++ [Path.basename(path) <> "_160x160", Path.extname(path)])
    dest_240x240 = Path.join(base ++ [Path.basename(path) <> "_240x240", Path.extname(path)])

    System.cmd("convert", [
      path,
      "-resize",
      "160x160^",
      "-gravity",
      "center",
      "-extent",
      "160x160",
      dest_160x160
    ])

    System.cmd("convert", [
      path,
      "-resize",
      "240x240^",
      "-gravity",
      "center",
      "-extent",
      "240x240",
      dest_240x240
    ])

    %{
      avatar_original_path:
        ~p"/uploads/avatars/#{resource_type}/#{resource.id}/#{Path.basename(dest)}",
      avatar_resized_paths: %{
        "160x160" =>
          ~p"/uploads/avatars/#{resource_type}/#{resource.id}/#{Path.basename(dest_160x160)}",
        "240x240" =>
          ~p"/uploads/avatars/#{resource_type}/#{resource.id}/#{Path.basename(dest_240x240)}"
      }
    }
  end
end
