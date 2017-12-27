defmodule Todos.TaskManagementTest do
  use Todos.ModelCase

  alias Todos.Accounts
  alias Todos.TaskManagement

  describe "todos" do
    alias Todos.TaskManagement.Todo

    @user_attrs %{email: "some email", name: "some name"}
    @valid_attrs %{description: "some description", title: "some title"}
    @update_attrs %{description: "some updated description", title: "some updated title"}
    @invalid_attrs %{description: nil, title: nil}

    def user_fixture() do
      {:ok, user} = Accounts.create_user(@user_attrs)
      user
    end

    def todo_fixture(attrs \\ %{}) do
      {:ok, owner} = Accounts.create_user(@user_attrs)
      todo_attrs = attrs
        |> Map.put(:owner_id, owner.id)
        |> Enum.into(@valid_attrs)
      {:ok, todo} = TaskManagement.create_todo(owner, todo_attrs)
      todo
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert TaskManagement.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert TaskManagement.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      owner = user_fixture()
      assert {:ok, %Todo{} = todo} = TaskManagement.create_todo(owner, @valid_attrs)
      assert todo.description == "some description"
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = TaskManagement.create_todo(owner, @invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, todo} = TaskManagement.update_todo(todo, @update_attrs)
      assert %Todo{} = todo
      assert todo.description == "some updated description"
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = TaskManagement.update_todo(todo, @invalid_attrs)
      assert todo == TaskManagement.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = TaskManagement.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> TaskManagement.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = TaskManagement.change_todo(todo)
    end
  end
end
