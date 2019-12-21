defmodule SpireWeb.FunctionHelper do
  def invoke(name, payload) do
    ExAws.Lambda.invoke(name, payload, "context")
    |> ExAws.request!()
  end
end