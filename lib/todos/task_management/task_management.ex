defmodule Todos.TaskManagement do
  @moduledoc """
  The TaskManagement context.
  """

  import Ecto.Query, warn: false
  alias Todos.Repo

  alias Todos.Accounts.User
  alias Todos.TaskManagement.Todo

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos(user)
      [%Todo{}, ...]

  """
  def list_todos(user) do
    query = from t in Todo,
      where: t.owner_id == ^user.id
    Repo.all(query)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(owner, %{field: value})
      {:ok, %Todo{}}

      iex> create_todo(owner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(%User{} = owner, attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Ecto.Changeset.put_change(:owner_id, owner.id)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{source: %Todo{}}

  """
  def change_todo(%Todo{} = todo) do
    Todo.changeset(todo, %{})
  end
end
