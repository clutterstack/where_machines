defmodule StructGenerator do
  @template """
  defmodule <%= module_name %> do
    @moduledoc "Automatically generated struct for <%= module_name %>"

    @enforce_keys <%= inspect(required_fields) %>
    defstruct <%= inspect(fields) %>

    @type t :: %__MODULE__{
      <%= for {name, type} <- typed_fields do
      %><%= name %>: <%= type %>,
      <% end %>}
  end
  """

  def generate_structs(input_file, output_file) do
    schemas = input_file
          |> File.read!()
          |> Jason.decode!()
          # from the decoded spec, get the stuff at the
          # components/schemas path
          |> get_in(["components", "schemas"])
          # |> IO.inspect(label: "schemas")

    struct_modules = schemas
          |> Enum.filter(fn {_, schema} -> Map.has_key?(schema, "properties") end)
          |> Enum.map(fn {name, schema} -> generate_struct("FlyMachinesApi.#{nice_struct_name(name)}", schema, schemas) end)
          |> Enum.join("\n\n")

    File.write!(output_file, struct_modules)
  end

  defp nice_struct_name(str) do
    if String.contains?(str, ".") do
      str
      |> String.split(".")
      |> List.update_at(0, &(String.capitalize(&1)))
      |> Enum.join()
    else
      str
    end
  end

  defp generate_struct(module_name, %{"properties" => properties} = schema, schemas) do
    fields = properties
      |> Map.keys()
      |> Enum.map(&String.to_atom/1)

    typed_fields = properties
    |> Enum.map(fn {name, prop} ->
      {String.to_atom(name), get_type(prop, schemas)}
    end)

    required_fields = (schema["required"] || []) |> Enum.map(&String.to_atom/1)

    EEx.eval_string(@template,
      module_name: module_name,
      required_fields: required_fields,
      fields: fields,
      typed_fields: typed_fields
    )
  end

  defp get_type(%{"$ref" => ref}, _schemas) do
    type_name = ref |> String.split("/") |> List.last() |> nice_struct_name()
    "%FlyMachinesApi.#{type_name}{}"
  end

  defp get_type(%{"type" => "object", "properties" => props}, schemas) do
    fields = props
    |> Enum.map(fn {name, prop} -> "#{name}: #{get_type(prop, schemas)}" end)
    |> Enum.join(", ")
    "%{#{fields}}"
  end

  defp get_type(%{"type" => "array", "items" => items}, schemas) do
    item_type = get_type(items, schemas)
    "list(#{item_type})"
  end

  defp get_type(%{"type" => "string"}, _), do: "String.t()"
  defp get_type(%{"type" => "integer"}, _), do: "integer()"
  defp get_type(%{"type" => "boolean"}, _), do: "boolean()"
  defp get_type(_, _), do: "any()"
end
