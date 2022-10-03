defmodule KsomniaWeb.AppLiveTest do
  use KsomniaWeb.ConnCase
  alias Ksomnia.App
  alias Ksomnia.Project
  alias Ksomnia.User

  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name", token: "some token"}
  @update_attrs %{name: "some updated name", token: "some updated token"}
  @invalid_attrs %{name: nil, token: nil}

  def create_app(opts) do
    {:ok, user} = User.create(%{email: "test@user", password: "password", username: "testuser"})
    {:ok, %{project: project}} = Project.create(user, %{name: "testing"})
    app = App.create(project.id, %{name: "app"})
    %{app: app, user: user}
  end

  describe "Displays user projects" do
    setup [:create_app]

    test "", %{conn: conn, app: app, user: user} do
      url = Routes.dashboard_index_path(conn, :index)
      Plug.Conn.fetch_session(conn)
      conn = put_session(conn, :user_id, user.id)
      {:ok, _index_live, html} = live(conn, url)
    end
  end

  describe "Index" do
    setup [:create_app]

    test "lists all apps", %{conn: conn, app: app} do
      {:ok, _index_live, html} = live(conn, Routes.app_index_path(conn, :index))

      assert html =~ "Listing Apps"
      assert html =~ app.name
    end

    test "saves new app", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.app_index_path(conn, :index))

      assert index_live |> element("a", "New App") |> render_click() =~
               "New App"

      assert_patch(index_live, Routes.app_index_path(conn, :new))

      assert index_live
             |> form("#app-form", app: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#app-form", app: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.app_index_path(conn, :index))

      assert html =~ "App created successfully"
      assert html =~ "some name"
    end

    test "updates app in listing", %{conn: conn, app: app} do
      {:ok, index_live, _html} = live(conn, Routes.app_index_path(conn, :index))

      assert index_live |> element("#app-#{app.id} a", "Edit") |> render_click() =~
               "Edit App"

      assert_patch(index_live, Routes.app_index_path(conn, :edit, app))

      assert index_live
             |> form("#app-form", app: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#app-form", app: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.app_index_path(conn, :index))

      assert html =~ "App updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes app in listing", %{conn: conn, app: app} do
      {:ok, index_live, _html} = live(conn, Routes.app_index_path(conn, :index))

      assert index_live |> element("#app-#{app.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#app-#{app.id}")
    end
  end

  describe "Show" do
    setup [:create_app]

    test "displays app", %{conn: conn, app: app} do
      {:ok, _show_live, html} = live(conn, Routes.app_show_path(conn, :show, app))

      assert html =~ "Show App"
      assert html =~ app.name
    end

    test "updates app within modal", %{conn: conn, app: app} do
      {:ok, show_live, _html} = live(conn, Routes.app_show_path(conn, :show, app))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit App"

      assert_patch(show_live, Routes.app_show_path(conn, :edit, app))

      assert show_live
             |> form("#app-form", app: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#app-form", app: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.app_show_path(conn, :show, app))

      assert html =~ "App updated successfully"
      assert html =~ "some updated name"
    end
  end
end
