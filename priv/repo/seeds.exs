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
Todos.Repo.insert!(%Todos.Accounts.User{
  name: "Test User",
  email: "test@user.com",
  password: "password",
})
