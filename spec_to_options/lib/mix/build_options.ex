defmodule Mix.Tasks.BuildOptions do
  use Mix.Task
  @impl Mix.Task

  def run(filename) do
    OpenApiToOptions.convert_file(filename)
    # |> File.write(new_file_path, [:write])
  end
end
