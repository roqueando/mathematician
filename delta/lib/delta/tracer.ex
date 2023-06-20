defmodule Delta.Tracer do
  @moduledoc """
    This will be used by a task async to send this trace to Oju server
  """

  require Logger

  def send(%{span_name: span_name, params: _params}) do
    case :gen_tcp.connect({127, 0, 0, 1}, 9090,  [:binary, active: false, packet: :line]) do
      {:ok, socket} -> send_trace(socket, span_name)
      {:error, error} -> Logger.error("Error on sending trace: #{inspect(error)}")
    end
  end

  defp send_trace(socket, span_name) do
    case  :gen_tcp.send(socket, mount_trace(span_name)) do
      :ok -> :ok
      {:error, error} -> Logger.error("Error sending tcp packet: #{inspect(error)}")
    end
  end

  @spec mount_trace(String.t()) :: binary()
  defp mount_trace(span_name) do
    {:ok, json} = %{
      "name" => span_name,
      "service" => "",
      "attributes" => %{},
    }
    |> Jason.encode()

    t = "TRACE delta AWO\n#{json}"
    IO.inspect(t)
    t
  end
end
