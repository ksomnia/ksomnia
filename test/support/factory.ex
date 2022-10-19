defmodule Ksomnia.Factory do
  use ExMachina.Ecto, repo: Ksomnia.Repo

  alias Ksomnia.User
  alias Ksomnia.Team
  alias Ksomnia.TeamUser
  alias Ksomnia.App

  def user_factory do
    %User{
      email: "test@user",
      username: "testuser"
    }
  end

  def team_factory do
    %Team{
      name: "team"
    }
  end

  def team_user_factory do
    %TeamUser{
      team: build(:team),
      user: build(:user)
    }
  end

  def app_factory do
    %App{
      name: "app",
      team: build(:team)
    }
  end
end
