defmodule Ksomnia.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_users" do
    field :project_id, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(project_user, attrs) do
    project_user
    |> cast(attrs, [:user_id, :project_id])
    |> validate_required([:user_id, :project_id])
  end
end
