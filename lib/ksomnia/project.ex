defmodule Ksomnia.Project do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.Project
  alias Ksomnia.ProjectUser
  alias Ksomnia.Repo
  alias Ecto.Multi

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "projects" do
    field :name, :string
    has_many :project_users, ProjectUser

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
  end

  def new(attrs) do
    %Project{}
    |> changeset(attrs)
  end

  def create(user, attrs) do
    Multi.new()
    |> Multi.insert(:project, new(attrs))
    |> Ecto.Multi.insert(:project_user, fn %{project: project} ->
      ProjectUser.new(project.id, user.id) |> IO.inspect()
    end)
    |> Repo.transaction()
  end

  def for_user(user) do
    from(p in Project,
      join: pu in assoc(p, :project_users),
      where: pu.user_id == ^user.id
    )
    |> Repo.all()
  end

  def all() do
    Repo.all(Project)
  end
end
