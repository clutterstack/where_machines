defmodule MachinesApiToEcto do


  def convert(input_file, output_dir) do
    File.mkdir_p(output_dir)
    spec = input_file |> File.read!() |> Jason.decode!()

    request_schemas = get_request_schemas(spec)

    schemas =
      spec
      |> get_in(["components", "schemas"])
      |> Enum.filter(fn {name, schema} ->
        is_map(schema) and name in request_schemas
      end)
      |> Map.new()

    schemas
    |> Enum.each(fn {name, schema} ->
      content = create_schema(sanitize_name(name), schema, schemas)
      file_path = Path.join(output_dir, "#{Macro.underscore(sanitize_name(name))}.ex")
      File.write!(file_path, content)
    end)
  end


defp get_request_schemas(spec) do
  spec["paths"]
  |> Enum.flat_map(fn {_path, path_item} ->
    path_item
    |> Enum.flat_map(fn {_method, operation} ->
      get_in(operation, ["requestBody", "content", "application/json", "schema", "$ref"])
      |> List.wrap()
      |> Enum.map(&String.replace(&1, "#/components/schemas/", ""))
    end)
  end)
  |> MapSet.new()
end

  defp create_schema(name, schema, all_schemas) do
    fields = get_fields(schema, all_schemas)
    changeset = get_changeset(schema, all_schemas)

    """
    defmodule FlyMachinesApi.Schemas.#{name} do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key false
      embedded_schema do
        #{fields}
      end

      def changeset(schema, attrs) do
        schema
        |> cast(attrs, [#{get_field_atoms(schema, all_schemas)}])
        #{changeset}
      end
    end
    """
  end

  defp get_fields(schema, all_schemas) do
    properties = get_properties(schema, all_schemas)
    properties
    |> Enum.map(fn {name, prop} -> "field :#{sanitize_field_name(name)}, #{get_type(prop, all_schemas)}" end)
    |> Enum.join("\n    ")
  end


  defp get_properties(%{"allOf" => [%{"$ref" => ref}]}, all_schemas) do
    get_ref_schema(ref, all_schemas)
    |> get_properties(all_schemas)
  end
  defp get_properties(schema, all_schemas) do
    case schema do
      %{"properties" => props} -> props
      %{"allOf" => schemas} ->
        schemas
        |> Enum.flat_map(fn s ->
          case s do
            %{"$ref" => ref} -> get_properties(get_ref_schema(ref, all_schemas), all_schemas)
            %{"properties" => props} -> Map.to_list(props)
            _ -> []
          end
        end)
        |> Map.new()
      _ -> %{}
    end
  end

  defp get_type(%{"allOf" => [%{"$ref" => ref}]}, _all_schemas) do
    "{:embed, #{get_module_name(ref)}}"
  end

  defp get_type(prop, all_schemas) do
    cond do
      Map.has_key?(prop, "$ref") ->
        "{:embed, #{get_module_name(prop["$ref"])}}"
      Map.has_key?(prop, "type") ->
        case prop["type"] do
          "string" -> ":string"
          "integer" -> ":integer"
          "number" -> ":float"
          "boolean" -> ":boolean"
          "array" -> "{:array, #{get_type(prop["items"], all_schemas)}}"
          "object" ->
            if Map.has_key?(prop, "properties") do
              ":map"
            else
              "{:embed, #{get_module_name(prop["$ref"])}}"
            end
          _ -> ":any"
        end
      true -> ":any"
    end
  end

  defp get_field_atoms(schema, all_schemas) do
    get_properties(schema, all_schemas)
    |> Map.keys()
    |> Enum.map(&":#{sanitize_field_name(&1)}")
    |> Enum.join(", ")
  end

  defp get_changeset(schema, all_schemas) do
    validations = [
      get_required_validation(schema, all_schemas),
      get_nested_validations(schema, all_schemas)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n    ")

    if validations == "", do: "", else: "    #{validations}"
  end

  defp get_required_validation(schema, all_schemas) do
    required =
      case schema do
        %{"required" => req} -> req
        %{"allOf" => schemas} ->
          schemas
          |> Enum.flat_map(fn s ->
            case s do
              %{"$ref" => ref} ->
                IO.inspect(ref, label: "a ref in allOf")
                get_required_validation(get_ref_schema(ref, all_schemas), all_schemas)
              %{"required" => req} -> req
              _ -> []
            end
          end)
        _ -> []
      end

    if Enum.empty?(required) do
      nil
    else
      fields = required |> Enum.map(&":#{sanitize_field_name(&1)}") |> Enum.join(", ")
      "|> validate_required([#{fields}])"
    end
  end

  defp get_nested_validations(schema, all_schemas) do
    get_properties(schema, all_schemas)
    |> Enum.map(fn {name, prop} -> get_nested_validation(name, prop, all_schemas) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n    ")
  end

  defp get_nested_validation(name, %{"allOf" => [%{"$ref" => ref}]}, _all_schemas) do
    module_name = get_module_name(ref)
    "|> cast_embed(:#{sanitize_field_name(name)}, with: &#{module_name}.changeset/2)"
  end
  defp get_nested_validation(name, %{"$ref" => ref}, _all_schemas) do
    module_name = get_module_name(ref)
    "|> cast_embed(:#{sanitize_field_name(name)}, with: &#{module_name}.changeset/2)"
  end
  defp get_nested_validation(name, %{"type" => "array", "items" => %{"$ref" => ref}}, _all_schemas) do
    module_name = get_module_name(ref)
    "|> cast_embed(:#{sanitize_field_name(name)}, with: &#{module_name}.changeset/2)"
  end
  defp get_nested_validation(name, %{"type" => "object", "$ref" => ref}, _all_schemas) do
    module_name = get_module_name(ref)
    "|> cast_embed(:#{sanitize_field_name(name)}, with: &#{module_name}.changeset/2)"
  end
  defp get_nested_validation(_, _, _), do: nil

  defp get_ref_schema(ref, all_schemas) do
    name = ref |> String.replace("#/components/schemas/", "")
    Map.get(all_schemas, name, %{})
  end

## Claude suggested this then adapting all other functions
## (like get_type) to
## handle the case where the reference doesn't exist?
## Not sure.
  # defp get_ref_schema(ref, all_schemas) do
  #   name = ref |> String.replace("#/components/schemas/", "")
  #   Map.get(all_schemas, name)
  # end

  defp get_module_name(ref) when is_binary(ref) do
    ref
    |> String.replace("#/components/schemas/", "")
    |> sanitize_name()
    |> (fn name -> "FlyMachinesApi.Schemas.#{name}" end).()
  end
  defp get_module_name(_), do: "UnknownSchema"

  defp sanitize_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize/1)
    |> Enum.join("")
  end

  defp sanitize_field_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.underscore/1)
    |> Enum.join("_")
  end
end
