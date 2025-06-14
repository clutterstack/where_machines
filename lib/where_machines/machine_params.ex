defmodule WhereMachines.MachineParams do

  def useless_params(source) do
    requestor_ip = System.get_env("FLY_PRIVATE_IP")

     # Set timeout based on source
    timeout = case source do
      :auto -> "60000"  # for auto-spawned
      :manual -> "600000"  # for manually spawned
    end

    %{
      config: %{
        env: %{
          "PHX_HOST": "useless-machine.fly.dev",
          "PORT": "4040",
          "PRIMARY_REGION": "yyz",
          "REQUESTOR_IP": requestor_ip,
          "REQUESTOR_API_PORT": "4001",
          "USELESS_MACHINE_END_STATE": "stopped", #if "stopped" (default), the Machine will stop after the sequence runs.
          "USELESS_MACHINE_FINAL_VIEW": "bye", # If "bye" (default), the liveview redirects to a controller view to close the ws connection
          "USELESS_MACHINE_LIFE_CYCLE_END": "stopped", # if "stopped" (default) the LifeCycle genserver shuts it down after TTL
          "USELESS_MACHINE_SHUTDOWN_TIMEOUT": timeout
        },
        guest: %{
          cpu_kind: "shared",
          cpus: 1,
          memory_mb: 512
        },
        services: [
          %{
            protocol: "tcp",
            internal_port: 4040,
            autostop: "off",
            autostart: false,
            min_machines_running: 0,
            ports: [
              %{
                port: 80,
                handlers: [
                  "http"
                ],
                force_https: false
              },
              %{
                port: 443,
                handlers: [
                  "http",
                  "tls"
                ]
              }
            ],
            concurrency: %{
              type: "connections",
              hard_limit: 25,
              soft_limit: 25
            }
          }
        ],
        # image: "registry.fly.io/useless-machine:yesplg-nochk-shutdown",
        # image: "registry.fly.io/useless-machine:yesplg-yeschk-shutdown",
        # image: "registry.fly.io/useless-machine:replay-cache-options",
        # image: "registry.fly.io/useless-machine:replay-cache-bye-shut-nicename",
        # image: "registry.fly.io/useless-machine:latest",
        # image: "registry.fly.io/useless-machine:what-on-earth",
        # image: "registry.fly.io/useless-machine:timeout-conf",
        # image: "registry.fly.io/useless-machine:status-fallback",
        # image: "registry.fly.io/useless-machine:new-text",
        image: "registry.fly.io/useless-machine:affinity-fix2",

        auto_destroy: true,
        restart: %{
          policy: "on-failure",
          max_retries: 2
        },
        stop_config: %{
        signal: "SIGTERM"
        }
      }
    }
  end

end
