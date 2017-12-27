defmodule Todos.UserViewTest do
  use Todos.ModelCase
  import Todos.Factory
  alias Todos.UserView

  test  "show.json" do
    todo = insert(:todo)
    user = insert(:user, todos: [todo])

    rendered_user = UserView.render("show.json", %{user: user})

    assert rendered_user == %{
      user: %{
        name: user.name,
        email: user.email,
        todos: [Todos.TodoView.todo_json(todo)]
      }
    }
  end
end
