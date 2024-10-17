defmodule Mix.Tasks.BuildStructs do
  use Mix.Task
  @impl Mix.Task

  # Usage example:
  # mix build_structs "spec.json" "generated_structs.ex"

  def run(args) do
    [infile, outfile] = args
    IO.inspect(args, label: "args")
    StructGenerator.generate_structs(infile, outfile)
    # |> File.write(new_file_path, [:write])
  end
end
