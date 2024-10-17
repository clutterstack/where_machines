defmodule OpenApiToOptions do
  @moduledoc """
  Initial vestion stubbed out using Claude 3.5 Sonnet, Oct 15 2024.
  Converts OpenAPI JSON schema to NimbleOptions schema format.
  """

  @doc """
  Main function to read spec.json and output NimbleOptions schemas.

  Usage:
  OpenApiToOptions.convert_file("spec.json") > schemas.ex
  """

  def convert_file(file_path) do
    full_spec =
      file_path
      |> File.read!()
      |> Jason.decode!()

    full_spec
    |> extract_schemas()
    |> Enum.map(&(convert_schema(&1, full_spec)))
    |> Enum.join("\n\n")
    |> write_to_file()
  end

  defp extract_schemas(spec) do
    get_in(spec, ["components", "schemas"])
    # Enum.map(schemas, fn {name, schema} -> {name, schema} end) # This looks redundant
  end

  defp convert_schema({name, schema}, full_spec) do
    schema_ast = schema |> to_nimble_options(full_spec) |> schema_to_ast()
    schema_string = Macro.to_string(schema_ast)

    """
    defmodule FlyMachinesApi.Schemas.#{name} do
      @schema #{schema_string}

      def schema, do: @schema
    end
    """
  end

  defp schema_to_ast(schema) when is_map(schema) do
    {:%{}, [], Enum.map(schema, fn {k, v} -> {k, schema_to_ast(v)} end)}
  end

  defp schema_to_ast(value) when is_list(value) do
    {:{}, [], Enum.map(value, &schema_to_ast/1)}
  end

  defp schema_to_ast(value), do: value

  defp resolve_ref(schema, full_spec) do
  case schema do
    %{"$ref" => ref} ->
      ref
      |> String.split("/")
      |> Enum.drop(1)  # Remove the leading '#'
      |> Enum.reduce(full_spec, &Map.get(&2, &1))
      |> resolve_ref(full_spec)  # Recursively resolve nested refs
    _ -> schema
  end
end

  defp write_to_file(contents, outfile \\ "latest_options.ex") do
      app_dir = File.cwd!
      new_file_path = Path.join( [app_dir, outfile]) #|> IO.inspect(label: "new_file_path")
      # contents |> IO.puts()
      File.write(new_file_path, contents)
    end

    defp to_nimble_options(schema, full_spec) do
      schema = resolve_ref(schema, full_spec)
      case schema do
        %{"type" => "object", "properties" => properties} ->
          required = Map.get(schema, "required", [])
          properties
          |> Enum.map(fn {key, value} ->
            {String.to_atom(key), property_to_nimble_options(value, full_spec, key in required)}
          end)
          |> Enum.into(%{})
        %{"type" => "array", "items" => items} ->
          [type: {:list, property_to_nimble_options(items, full_spec)}]
        _ -> property_to_nimble_options(schema, full_spec)
      end
    end

  defp property_to_nimble_options(property, full_spec, required \\ false) do
    property = resolve_ref(property, full_spec)
    base = [
      type: get_type(property),
      required: required
    ]
    base
    |> add_enum(property)
    |> add_items(property, full_spec)
    |> add_properties(property, full_spec)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  defp get_type(%{"type" => "string"}), do: :string
  defp get_type(%{"type" => "integer"}), do: :integer
  defp get_type(%{"type" => "number"}), do: :float
  defp get_type(%{"type" => "boolean"}), do: :boolean
  defp get_type(%{"type" => "array"}), do: :list
  defp get_type(%{"type" => "object"}), do: :map
  defp get_type(_), do: :any

  defp add_enum(options, %{"enum" => enum}) do
    Keyword.put(options, :enum, enum)
  end

  defp add_enum(options, _), do: options

  defp add_items(options, %{"type" => "array", "items" => items}, full_spec) do
    Keyword.put(options, :items, property_to_nimble_options(items, full_spec))
  end

  defp add_items(options, _, _), do: options

  defp add_properties(options, %{"type" => "object", "properties" => properties}, full_spec) do
    nested_schema = to_nimble_options(%{"type" => "object", "properties" => properties}, full_spec)
    Keyword.put(options, :keys, nested_schema)
  end

  defp add_properties(options, _, _), do: options
end
