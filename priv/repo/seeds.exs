# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todos.Repo.insert!(%Todos.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will halt execution if something goes wrong.
user = Todos.Repo.insert!(%Todos.Accounts.User{
  name: "Test User",
  email: "test@user.com",
  password: "password",
})

other_user = Todos.Repo.insert!(%Todos.Accounts.User{
  name: "Test User 2",
  email: "test2@user.com",
  password: "password",
})

Enum.map(1..3, fn i ->
  Todos.Repo.insert!(%Todos.TaskManagement.Todo{
    title: "Todo #{i}",
    description: "Description for todo #{i}",
    owner_id: user.id
  })
end)

Enum.map(4..5, fn i ->
  Todos.Repo.insert!(%Todos.TaskManagement.Todo{
    title: "Todo #{i}",
    description: "Description for todo #{i}",
    owner_id: other_user.id
  })
end)
