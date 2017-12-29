defmodule Todos.Router do
  use Todos.Web, :router

  import Todos.Guardian
  import Guardian.Plug

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

  pipeline :authenticated do
    plug Guardian.Plug.Pipeline,
      module: Todos.Guardian,
      error_handler: Todos.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, allow_blank: false
  end

  scope "/", Todos do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/api/auth", Todos do
    pipe_through [:api]
    post "/login", UserController, :login
    put "/logout", UserController, :logout
    post "/register", UserController, :create
  end

  scope "/api", Todos do
    pipe_through [:api, :authenticated]

    resources "/todos", TodoController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :create, :edit, :delete]
  end
end
