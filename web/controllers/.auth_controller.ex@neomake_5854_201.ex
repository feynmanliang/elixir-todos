defmodule Todos.AuthController do
  use Todos.Web, :controller
  plug Ueberauth

  alias Ueberauth.Auth

  action_fallback Todos.FallbackController

  def callback(%{assigns: %{uberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.puts auth
    case find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      { :error, reason } ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp find_or_create(%Auth{provider: :identity} = auth) do
    case validate_pass(auth.credentials) do
      :ok ->
        {:ok, basic_info(auth)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: auth.info.name, email: auth.info.email}
  end

  defp validate_pass(%{other: %{password: pw}}) do
    :ok
  end
  defp validate_pass(_), do: {:error, "Password required"}
end
