defmodule Todos.TodoControllerTest do
  use Todos.ConnCase

  alias Todos.Accounts
  alias Todos.TaskManagement
  alias Todos.TaskManagement.Todo

  @create_user_attrs %{email: "some email", name: "some name", password: "some password"}
  @create_todo_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  def fixture(:todo, owner) do
    {:ok, todo} = TaskManagement.create_todo(owner, @create_todo_attrs)
    todo
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user]

    test "lists all todos", %{conn: conn, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> get(todo_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create todo" do
    setup [:create_user]

    test "renders todo when data is valid", %{conn: conn, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> post(todo_path(conn, :create), todo: @create_todo_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = build_conn()
             |> put_req_header("authorization", "bearer #{jwt}")
             |> get(todo_path(conn, :show, id))
      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["description"] == "some description"
      assert response["title"] == "some title"
    end

    test "renders errors when not authenticated", %{conn: conn} do
      conn = post conn, todo_path(conn, :create), todo: @invalid_attrs
      assert response(conn, 401)
    end

    test "renders errors when data is invalid", %{conn: conn, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> post(todo_path(conn, :create), todo: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update todo" do
    setup [:create_user, :create_todo]

    test "renders todo when data is valid", %{conn: conn, todo: %Todo{id: id} = todo, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> put(todo_path(conn, :update, todo), todo: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = build_conn()
             |> put_req_header("authorization", "bearer #{jwt}")
             |> get(todo_path(conn, :show, id))
      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["description"] == "some updated description"
      assert response["title"] == "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, todo: todo, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> put(todo_path(conn, :update, todo), todo: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete todo" do
    setup [:create_user, :create_todo]

    test "deletes chosen todo", %{conn: conn, todo: todo, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> delete(todo_path(conn, :delete, todo))
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        build_conn()
        |> put_req_header("authorization", "bearer #{jwt}")
        |> get(todo_path(conn, :show, todo))
      end
    end
  end

  defp create_todo(context) do
    todo = fixture(:todo, context.user)
    {:ok, todo: todo}
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    {:ok, jwt, _} = Todos.Guardian.encode_and_sign(user)
    {:ok, user: user, jwt: jwt}
  end
end
