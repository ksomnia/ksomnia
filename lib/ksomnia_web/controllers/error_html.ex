defmodule KsomniaWeb.ErrorHTML do
  use KsomniaWeb, :html
  require Logger

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/newphoenix_web/controllers/error_html/404.html.heex
  #   * lib/newphoenix_web/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  def render("500.html", assigns) do
    Logger.error(Exception.format(:error, assigns[:reason], assigns[:stack]))
    "Internal system error"
  end

  def render("404.html", _assigns) do
    "Page Not Found"
  end

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
