defmodule Delta.Router do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  post "/check-delta" do
    case Delta.Calculate.run(conn.body_params) do
      :delta_has_no_result ->
        conn
        |> send_resp(400, "Delta has no result")
      result ->
        conn
        |> send_resp(200, result |> to_string())
    end
  end

  match _ do
    send_resp(conn, 404, "Oops, route not found!")
  end
end
