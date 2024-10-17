defmodule FlyMachinesApi.ImageRef do
  @moduledoc "Automatically generated struct for FlyMachinesApi.ImageRef"

  @enforce_keys []
  defstruct [:digest, :labels, :registry, :repository, :tag]

  @type t :: %__MODULE__{
    digest: String.t(),
    labels: any(),
    registry: String.t(),
    repository: String.t(),
    tag: String.t(),
    }
end
