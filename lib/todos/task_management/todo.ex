defmodule Todos.TaskManagement.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Todos.Accounts.User
  alias Todos.TaskManagement.Todo


  schema "todos" do
    field :description, :string
    field :title, :string
    belongs_to :user, User, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(%Todo{} = todo, attrs) do
    todo
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
