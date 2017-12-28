defmodule Todos.UserView do
  use Todos.Web, :view
  alias Todos.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email}
  end

  def render("access_token.json", %{token: token}) do
    %{access_token: token}
  end
end
