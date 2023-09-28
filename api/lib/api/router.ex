defmodule Api.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(:match)
  plug(:dispatch)

  get "/lookup/:ip_address" do
    with {:ok, _} <- ip_address |> to_charlist() |> :inet.parse_ipv4_address(),
         %GeoIP.LookupResponse{} = response <- GeoIP.lookup(ip_address) do
      send_json(conn, 200, %{data: response})
    else
      {:error, :einval} ->
        send_json(conn, 400, %{error: "ip address is not valid"})

      nil ->
        send_json(conn, 404, %{error: "ip address is not found"})
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp send_json(conn, status_code, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status_code, Jason.encode!(body))
  end
end
