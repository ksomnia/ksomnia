defmodule Ksomnia.ProjectUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ksomnia.ProjectUser
  alias Ksomnia.Project
  alias Ksomnia.User

  schema "project_users" do
    belongs_to :project, Project, type: Ksomnia.ShortUUID6
    belongs_to :user, User, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(project_user, attrs) do
    project_user
    |> cast(attrs, [:user_id, :project_id])
    |> validate_required([:user_id, :project_id])
  end

  def new(project_id, user_id) do
    %ProjectUser{project_id: project_id, user_id: user_id}
  end
end
