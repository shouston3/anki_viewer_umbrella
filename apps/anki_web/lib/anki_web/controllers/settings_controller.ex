defmodule AnkiWeb.SettingsController do
  use AnkiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end