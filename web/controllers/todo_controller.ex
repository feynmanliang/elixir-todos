defmodule Todos.TodoController do
  use Todos.Web, :controller

  alias Todos.TaskManagement
  alias Todos.TaskManagement.Todo

  action_fallback Todos.FallbackController

  def index(conn, _params) do
    todos = TaskManagement.list_todos()
    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    with {:ok, %Todo{} = todo} <- TaskManagement.create_todo(todo_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", todo_path(conn, :show, todo))
      |> render("show.json", todo: todo)
    end
  end

  def show(conn, %{"id" => id}) do
    todo = TaskManagement.get_todo!(id)
    render(conn, "show.json", todo: todo)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = TaskManagement.get_todo!(id)

    with {:ok, %Todo{} = todo} <- TaskManagement.update_todo(todo, todo_params) do
      render(conn, "show.json", todo: todo)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = TaskManagement.get_todo!(id)
    with {:ok, %Todo{}} <- TaskManagement.delete_todo(todo) do
      send_resp(conn, :no_content, "")
    end
  end
end
