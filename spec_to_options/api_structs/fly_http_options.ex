defmodule FlyMachinesApi.FlyHTTPOptions do
  @moduledoc "Automatically generated struct for FlyMachinesApi.FlyHTTPOptions"

  @enforce_keys []
  defstruct [:compress, :h2_backend, :headers_read_timeout, :idle_timeout, :response]

  @type t :: %__MODULE__{
    compress: boolean(),
    h2_backend: boolean(),
    headers_read_timeout: integer(),
    idle_timeout: integer(),
    response: %FlyMachinesApi.FlyHTTPResponseOptions{},
    }
end
