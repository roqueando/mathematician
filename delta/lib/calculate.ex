defmodule Delta.Calculate do

  def run(%{"a" => a, "b" => b, "c" => c} = params) do
    Delta.Tracer.send(%{span_name: "checking-delta", params: params})
    {a, _} = Integer.parse(a)
    {b, _} = Integer.parse(b)
    {c, _} = Integer.parse(c)
    case :math.pow(b, 2) - 4 * a * c do
      n when n > 0 -> n
      _ -> :delta_has_no_result
    end
  end
end
