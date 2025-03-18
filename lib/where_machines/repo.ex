defmodule WhereMachines.Repo do
  use Ecto.Repo,
    otp_app: :where_machines,
    adapter: Ecto.Adapters.SQLite3
end
