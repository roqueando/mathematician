defmodule Delta.Router do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Jason
  plug :match
  plug :dispatch

  post "/check-delta" do
    result = Delta.Calculate.run(conn.body_params)
    send_resp(conn, 200, "The result is: #{result}")
  end

  match _ do
    send_resp(conn, 404, "Oops, route not found!")
  end
end
