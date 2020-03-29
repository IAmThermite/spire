defmodule Spire.Utils do

  def struct_to_json_map(struct, fields_to_drop \\ [])

  def struct_to_json_map(%_{} = struct, fields_to_drop) do
    Map.from_struct(struct)
    |> Map.drop([:__meta__])
    |> Map.drop(fields_to_drop)
  end

  def struct_to_json_map(%{} = struct, fields_to_drop) do
    Map.drop(struct, fields_to_drop)
  end

  def struct_to_json_map(_, _) do
    %{}
  end
end
