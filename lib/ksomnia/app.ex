defmodule Ksomnia.App do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ksomnia.App
  alias Ksomnia.Project
  alias Ksomnia.Repo

  @primary_key {:id, Ksomnia.ShortUUID6, autogenerate: true}

  schema "apps" do
    field :name, :string
    field :token, :string
    belongs_to :project, Project, type: Ksomnia.ShortUUID6

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_token()
  end

  def put_token(changeset) do
    if changeset.data.token do
      changeset
    else
      put_change(changeset, :token, Ksomnia.Security.random_string(16))
    end
  end

  def all() do
    Repo.all(App)
  end

  def update(app, attrs) do
    app
    |> changeset(attrs)
    |> Repo.update()
  end

  def create(project_id, attrs) when is_binary(project_id) do
    %App{project_id: project_id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def for_project(project_id) do
    from(a in App,
      where: a.project_id == ^project_id
    )
    |> Repo.all()
  end
end
