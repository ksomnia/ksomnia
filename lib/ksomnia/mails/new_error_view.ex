defmodule Ksomnia.Mails.NewErrorView do
  use KsomniaWeb, :live_component

  def render(assigns) do
    ~H"""
    <a href={"https://" <> @host <> ~p"/error_identities/#{@error_identity.id}"}>
      New error occurred at <strong><%= @app.name %></strong> (Commit: <%= @hash %>):
    </a>

    <pre>
      <%= @error_identity.message %>
      <%= @error_identity.stacktrace %>
    </pre>
    """
  end
end
