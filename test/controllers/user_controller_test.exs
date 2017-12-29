defmodule Todos.UserControllerTest do
  use Todos.ConnCase

  import Poison

  alias Todos.Accounts
  alias Todos.Accounts.User

  @create_attrs %{email: "some email", name: "some name", password: "some password"}
  @update_attrs %{email: "some updated email", name: "some updated name", password: "some updated password"}
  @invalid_attrs %{email: nil, name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = post conn, user_path(conn, :login), email: @create_attrs.email, password: @create_attrs.password
      jwt_token =
        Poison.decode!(response(conn, 200))["access_token"]

      conn = build_conn()
             |> put_req_header("authorization", "bearer #{jwt_token}")
             |> get(user_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some email",
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> put(user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = build_conn()
             |> put_req_header("authorization", "bearer #{jwt}")
             |> get(user_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some updated email",
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, jwt: jwt} do
      conn = conn
             |> put_req_header("authorization", "bearer #{jwt}")
             |> put(user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, jwt, _} = Todos.Guardian.encode_and_sign(user)
    {:ok, user: user, jwt: jwt}
  end
end
