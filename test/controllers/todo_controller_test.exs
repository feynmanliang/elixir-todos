defmodule Todos.TodoControllerTest do
  use Todos.ConnCase

  alias Todos.TaskManagement
  alias Todos.TaskManagement.Todo

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  def fixture(:todo, owner) do
    {:ok, todo} = TaskManagement.create_todo(owner, @create_attrs)
    todo
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all todos", %{conn: conn} do
      conn = get conn, todo_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create todo" do
    setup [:create_user]

    test "renders todo when data is valid", %{conn: conn} do
      conn = post conn, todo_path(conn, :create), todo: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, todo_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some description",
        "title" => "some title"}
    end

    test "renders errors when no owner is provided", %{conn: conn} do
      conn = post conn, todo_path(conn, :create), todo: @invalid_attrs
      # TODO: is this the correct error
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, todo_path(conn, :create), todo: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update todo" do
    setup [:create_todo]

    test "renders todo when data is valid", %{conn: conn, todo: %Todo{id: id} = todo} do
      conn = put conn, todo_path(conn, :update, todo), todo: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, todo_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some updated description",
        "title" => "some updated title"}
    end

    test "renders errors when data is invalid", %{conn: conn, todo: todo} do
      conn = put conn, todo_path(conn, :update, todo), todo: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete todo" do
    setup [:create_todo]

    test "deletes chosen todo", %{conn: conn, todo: todo} do
      conn = delete conn, todo_path(conn, :delete, todo)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, todo_path(conn, :show, todo)
      end
    end
  end

  defp create_todo(_) do
    owner = Todos.UserControllerTest.fixture(:user)
    todo = fixture(:todo, owner)
    {:ok, todo: todo}
  end

  defp create_user(_) do
    user = Todos.UserControllerTest.fixture(:user)
    {:ok, user: user}
  end
end
