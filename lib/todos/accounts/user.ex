defmodule Todos.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Todos.Accounts.User
  alias Todos.TaskManagement.Todo


  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    has_many :todos, Todo, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
  end
end
