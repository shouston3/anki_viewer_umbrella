defmodule AnkiWeb.Router do
  use AnkiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AnkiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    get "/rules", RulesController, :index
    get "/search", SearchController, :index
    get "/settings", SettingsController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AnkiWeb do
  #   pipe_through :api
  # end
end
