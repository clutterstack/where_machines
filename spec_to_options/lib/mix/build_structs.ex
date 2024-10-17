defmodule Mix.Tasks.BuildStructs do
  use Mix.Task
  @impl Mix.Task

  # Usage example:
  # mix build_structs "spec.json" "generated_structs.ex"

  def run(args) do
    [infile, outdir] = args
    IO.inspect(args, label: "args")
    StructGenerator.generate_structs(infile, outdir)
    # |> File.write(new_file_path, [:write])
  end
end
