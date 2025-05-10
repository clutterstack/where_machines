defmodule WhereMachinesWeb.Presence do
  use Phoenix.Presence,
    otp_app: :where_machines,
    pubsub_server: :where_pubsub
end
