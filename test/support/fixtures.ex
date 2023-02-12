defmodule Ksomnia.Fixtures do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ksomnia.Mutations.UserMutations
      alias Ksomnia.Mutations.TeamMutations
      alias Ksomnia.Mutations.TeamUserMutations
      alias Ksomnia.Mutations.InviteMutations
      alias Ksomnia.Mutations.AppMutations
      alias Ksomnia.Mutations.ErrorIdentityMutations
      alias Ksomnia.Queries.TeamQueries
      alias Ksomnia.Queries.UserQueries
      alias Ksomnia.App
      alias Ksomnia.Repo
      alias Ksomnia.Invite
      alias Ksomnia.TeamUser
      alias Ksomnia.ErrorIdentity

      def repo_count(query) do
        Repo.count(query)
      end

      def repo_all(query) do
        Repo.all(query)
      end

      def create_user(attrs \\ []) do
        attrs = Enum.into(attrs, %{})

        UserMutations.create(
          attrs
          |> Map.put_new_lazy(:email, fn -> Faker.Internet.email() end)
          |> Map.put_new_lazy(:username, fn -> Faker.Internet.user_name() end)
          |> Map.put_new(:password, "password")
        )
      end

      def create_user!(attrs \\ []) do
        {:ok, user} = create_user(attrs)
        user
      end

      def create_team(user, attrs \\ []) do
        attrs = Enum.into(attrs, %{})

        {:ok, %{team: team}} =
          TeamMutations.create(
            user,
            attrs
            |> Map.put_new_lazy(:name, fn -> Faker.Company.name() end)
          )

        {:ok, team}
      end

      def create_team!(user, attrs \\ []) do
        {:ok, team} = create_team(user, attrs)
        team
      end

      def create_invite(team, inviter, attrs \\ []) do
        attrs = Enum.into(attrs, %{})

        InviteMutations.create(team.id, inviter.id, %{
          email: attrs[:email]
        })
      end

      def create_invite!(team, inviter, attrs \\ []) do
        {:ok, invite} = create_invite(team, inviter, attrs)
        invite
      end

      def add_user_to_team!(team, inviter, invitee) do
        invite = create_invite!(team, inviter, %{email: invitee.email})
        {:ok, _} = InviteMutations.accept(invite.id, invitee)
      end

      def make_owner(team, user) do
        TeamUserMutations.make_owner(team.id, user.id)
      end

      def create_app(team, user, attrs \\ []) do
        attrs = Enum.into(attrs, %{})

        AppMutations.create(
          team.id,
          user.id,
          attrs
          |> Map.put_new_lazy(:name, fn ->
            Faker.App.name()
          end)
        )
        |> case do
          {:ok, %{app: app}} ->
            {:ok, app}

          error ->
            error
        end
      end

      def create_app!(team, user, attrs \\ []) do
        {:ok, app} = create_app(team, user, attrs)
        app
      end
    end
  end
end
