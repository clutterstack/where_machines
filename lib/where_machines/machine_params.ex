defmodule WhereMachines.MachineParams do

  def useless_params do
    %{
      config: %{
        env: %{
          "PHX_HOST": "useless-machine.fly.dev",
          "PORT": "4040",
          "PRIMARY_REGION": "yyz"
        },
        guest: %{
          cpu_kind: "shared",
          cpus: 1,
          memory_mb: 1024
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
              hard_limit: 100,
              soft_limit: 50
            }
          }
        ],
        image: "registry.fly.io/useless-machine:deployment-01JPK0A3C6SRTFRN81142J1TWY",
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
