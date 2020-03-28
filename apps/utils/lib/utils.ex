defmodule Spire.Utils do
  def struct_to_json_map(struct, fields_to_drop \\ []) do
    Map.from_struct(struct)
    |> Map.drop([:__meta__])
    |> Map.drop(fields_to_drop)
  end
end
