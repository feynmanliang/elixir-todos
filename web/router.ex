defmodule Todos.Router do
  use Todos.Web, :router
  alias Todos.Guardian

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
    plug :ensure_jwt
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

  defp ensure_jwt(conn, _params) do
    with {:ok, user, _claims} <- conn
    |> get_req_header("bearer")
    |> Enum.at(0)
    |> Guardian.resource_from_token() do
      assign(conn, :user, user)
    else
      _ ->
        conn
        |> send_resp(401, "Invalid credentials")
        |> halt()
    end
  end
end
