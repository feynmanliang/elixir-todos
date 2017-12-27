defmodule Todos.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :description, :text
      add :owner_id, references(:users, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:todos, [:owner_id])
  end
end
