defmodule FlyMachinesApi.FlyStatic do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyStatic"

  @enforce_keys [:guest_path, :url_prefix]
  defstruct [:guest_path, :index_document, :tigris_bucket, :url_prefix]

  @type t :: %__MODULE__{
    guest_path: String.t(),
    index_document: String.t(),
    tigris_bucket: String.t(),
    url_prefix: String.t(),
    }
end
