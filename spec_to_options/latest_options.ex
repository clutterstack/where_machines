defmodule FlyMachinesApi.Schemas.CheckStatus do
  @schema %{
  name: %{type: :string, required: false},
  output: %{type: :string, required: false},
  status: %{type: :string, required: false},
  updated_at: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineConfig do
  @schema %{
  env: %{type: :map, required: false},
  init: %{
    type: :map,
    keys: %{
      tty: %{type: :boolean, required: false},
      exec: %{type: :list, items: %{type: :string, required: false}, required: false},
      cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
      kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
      entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
      swap_size_mb: %{type: :integer, required: false}
    },
    required: false
  },
  processes: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        env: %{type: :map, required: false},
        user: %{type: :string, required: false},
        exec: %{type: :list, items: %{type: :string, required: false}, required: false},
        cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
        entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
        env_from: %{
          type: :list,
          items: %{
            type: :map,
            keys: %{
              env_var: %{type: :string, required: false},
              field_ref: %{
                type: :string,
                enum: {"id", "version", "app_name", "private_ip", "region", "image"},
                required: false
              }
            },
            required: false
          },
          required: false
        },
        ignore_app_secrets: %{type: :boolean, required: false},
        secrets: %{
          type: :list,
          items: %{
            type: :map,
            keys: %{
              name: %{type: :string, required: false},
              env_var: %{type: :string, required: false}
            },
            required: false
          },
          required: false
        }
      },
      required: false
    },
    required: false
  },
  restart: %{
    type: :map,
    keys: %{
      gpu_bid_price: %{type: :float, required: false},
      max_retries: %{type: :integer, required: false},
      policy: %{
        type: :string,
        enum: {"no", "always", "on-failure", "spot-price"},
        required: false
      }
    },
    required: false
  },
  size: %{type: :string, required: false},
  metadata: %{type: :map, required: false},
  image: %{type: :string, required: false},
  dns: %{
    type: :map,
    keys: %{
      options: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            name: %{type: :string, required: false},
            value: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      nameservers: %{type: :list, items: %{type: :string, required: false}, required: false},
      hostname: %{type: :string, required: false},
      dns_forward_rules: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            addr: %{type: :string, required: false},
            basename: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      hostname_fqdn: %{type: :string, required: false},
      searches: %{type: :list, items: %{type: :string, required: false}, required: false},
      skip_registration: %{type: :boolean, required: false}
    },
    required: false
  },
  services: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        ports: %{
          type: :list,
          items: %{
            type: :map,
            keys: %{
              port: %{type: :integer, required: false},
              handlers: %{type: :list, items: %{type: :string, required: false}, required: false},
              start_port: %{type: :integer, required: false},
              http_options: %{
                type: :map,
                keys: %{
                  compress: %{type: :boolean, required: false},
                  response: %{
                    type: :map,
                    keys: %{
                      headers: %{type: :map, required: false},
                      pristine: %{type: :boolean, required: false}
                    },
                    required: false
                  },
                  h2_backend: %{type: :boolean, required: false},
                  headers_read_timeout: %{type: :integer, required: false},
                  idle_timeout: %{type: :integer, required: false}
                },
                required: false
              },
              end_port: %{type: :integer, required: false},
              force_https: %{type: :boolean, required: false},
              proxy_proto_options: %{
                type: :map,
                keys: %{version: %{type: :string, required: false}},
                required: false
              },
              tls_options: %{
                type: :map,
                keys: %{
                  versions: %{
                    type: :list,
                    items: %{type: :string, required: false},
                    required: false
                  },
                  alpn: %{type: :list, items: %{type: :string, required: false}, required: false},
                  default_self_signed: %{type: :boolean, required: false}
                },
                required: false
              }
            },
            required: false
          },
          required: false
        },
        protocol: %{type: :string, required: false},
        checks: %{
          type: :list,
          items: %{
            type: :map,
            keys: %{
              timeout: %{type: :map, required: false},
              port: %{type: :integer, required: false},
              type: %{type: :string, required: false},
              path: %{type: :string, required: false},
              protocol: %{type: :string, required: false},
              interval: %{type: :map, required: false},
              kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
              headers: %{
                type: :list,
                items: %{
                  type: :map,
                  keys: %{
                    name: %{type: :string, required: false},
                    values: %{
                      type: :list,
                      items: %{type: :string, required: false},
                      required: false
                    }
                  },
                  required: false
                },
                required: false
              },
              grace_period: %{type: :map, required: false},
              method: %{type: :string, required: false},
              tls_server_name: %{type: :string, required: false},
              tls_skip_verify: %{type: :boolean, required: false}
            },
            required: false
          },
          required: false
        },
        autostart: %{type: :boolean, required: false},
        autostop: %{type: :string, enum: {"off", "stop", "suspend"}, required: false},
        concurrency: %{
          type: :map,
          keys: %{
            type: %{type: :string, required: false},
            hard_limit: %{type: :integer, required: false},
            soft_limit: %{type: :integer, required: false}
          },
          required: false
        },
        force_instance_description: %{type: :string, required: false},
        force_instance_key: %{type: :string, required: false},
        internal_port: %{type: :integer, required: false},
        min_machines_running: %{type: :integer, required: false}
      },
      required: false
    },
    required: false
  },
  files: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        mode: %{type: :integer, required: false},
        guest_path: %{type: :string, required: false},
        raw_value: %{type: :string, required: false},
        secret_name: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  auto_destroy: %{type: :boolean, required: false},
  checks: %{type: :map, required: false},
  disable_machine_autostart: %{type: :boolean, required: false},
  guest: %{
    type: :map,
    keys: %{
      cpu_kind: %{type: :string, required: false},
      cpus: %{type: :integer, required: false},
      gpu_kind: %{type: :string, required: false},
      gpus: %{type: :integer, required: false},
      host_dedication_id: %{type: :string, required: false},
      kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
      memory_mb: %{type: :integer, required: false}
    },
    required: false
  },
  metrics: %{
    type: :map,
    keys: %{port: %{type: :integer, required: false}, path: %{type: :string, required: false}},
    required: false
  },
  mounts: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        name: %{type: :string, required: false},
        path: %{type: :string, required: false},
        add_size_gb: %{type: :integer, required: false},
        encrypted: %{type: :boolean, required: false},
        extend_threshold_percent: %{type: :integer, required: false},
        size_gb: %{type: :integer, required: false},
        size_gb_limit: %{type: :integer, required: false},
        volume: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  schedule: %{type: :string, required: false},
  standbys: %{type: :list, items: %{type: :string, required: false}, required: false},
  statics: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        guest_path: %{type: :string, required: false},
        index_document: %{type: :string, required: false},
        tigris_bucket: %{type: :string, required: false},
        url_prefix: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  stop_config: %{
    type: :map,
    keys: %{
      timeout: %{
        type: :map,
        keys: %{"time.Duration": %{type: :integer, required: false}},
        required: false
      },
      signal: %{type: :string, required: false}
    },
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateSecretRequest do
  @schema %{value: %{type: :list, items: %{type: :integer, required: false}, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyDuration do
  @schema %{"time.Duration": %{type: :integer, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateMachineRequest do
  @schema %{
  name: %{type: :string, required: false},
  config: %{type: :map, required: false},
  lease_ttl: %{type: :integer, required: false},
  lsvd: %{type: :boolean, required: false},
  region: %{type: :string, required: false},
  skip_launch: %{type: :boolean, required: false},
  skip_service_registration: %{type: :boolean, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.MachineVersion do
  @schema %{
  version: %{type: :string, required: false},
  user_config: %{
    type: :map,
    keys: %{
      env: %{type: :map, required: false},
      init: %{
        type: :map,
        keys: %{
          tty: %{type: :boolean, required: false},
          exec: %{type: :list, items: %{type: :string, required: false}, required: false},
          cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
          swap_size_mb: %{type: :integer, required: false}
        },
        required: false
      },
      processes: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            env: %{type: :map, required: false},
            user: %{type: :string, required: false},
            exec: %{type: :list, items: %{type: :string, required: false}, required: false},
            cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
            entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
            env_from: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  env_var: %{type: :string, required: false},
                  field_ref: %{
                    type: :string,
                    enum: {"id", "version", "app_name", "private_ip", "region", "image"},
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            ignore_app_secrets: %{type: :boolean, required: false},
            secrets: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  name: %{type: :string, required: false},
                  env_var: %{type: :string, required: false}
                },
                required: false
              },
              required: false
            }
          },
          required: false
        },
        required: false
      },
      restart: %{
        type: :map,
        keys: %{
          gpu_bid_price: %{type: :float, required: false},
          max_retries: %{type: :integer, required: false},
          policy: %{
            type: :string,
            enum: {"no", "always", "on-failure", "spot-price"},
            required: false
          }
        },
        required: false
      },
      size: %{type: :string, required: false},
      metadata: %{type: :map, required: false},
      image: %{type: :string, required: false},
      dns: %{
        type: :map,
        keys: %{
          options: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                name: %{type: :string, required: false},
                value: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          nameservers: %{type: :list, items: %{type: :string, required: false}, required: false},
          hostname: %{type: :string, required: false},
          dns_forward_rules: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                addr: %{type: :string, required: false},
                basename: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          hostname_fqdn: %{type: :string, required: false},
          searches: %{type: :list, items: %{type: :string, required: false}, required: false},
          skip_registration: %{type: :boolean, required: false}
        },
        required: false
      },
      services: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            ports: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  port: %{type: :integer, required: false},
                  handlers: %{
                    type: :list,
                    items: %{type: :string, required: false},
                    required: false
                  },
                  start_port: %{type: :integer, required: false},
                  http_options: %{
                    type: :map,
                    keys: %{
                      compress: %{type: :boolean, required: false},
                      response: %{
                        type: :map,
                        keys: %{
                          headers: %{type: :map, required: false},
                          pristine: %{type: :boolean, required: false}
                        },
                        required: false
                      },
                      h2_backend: %{type: :boolean, required: false},
                      headers_read_timeout: %{type: :integer, required: false},
                      idle_timeout: %{type: :integer, required: false}
                    },
                    required: false
                  },
                  end_port: %{type: :integer, required: false},
                  force_https: %{type: :boolean, required: false},
                  proxy_proto_options: %{
                    type: :map,
                    keys: %{version: %{type: :string, required: false}},
                    required: false
                  },
                  tls_options: %{
                    type: :map,
                    keys: %{
                      versions: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      alpn: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      default_self_signed: %{type: :boolean, required: false}
                    },
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            protocol: %{type: :string, required: false},
            checks: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  timeout: %{type: :map, required: false},
                  port: %{type: :integer, required: false},
                  type: %{type: :string, required: false},
                  path: %{type: :string, required: false},
                  protocol: %{type: :string, required: false},
                  interval: %{type: :map, required: false},
                  kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
                  headers: %{
                    type: :list,
                    items: %{
                      type: :map,
                      keys: %{
                        name: %{type: :string, required: false},
                        values: %{
                          type: :list,
                          items: %{type: :string, required: false},
                          required: false
                        }
                      },
                      required: false
                    },
                    required: false
                  },
                  grace_period: %{type: :map, required: false},
                  method: %{type: :string, required: false},
                  tls_server_name: %{type: :string, required: false},
                  tls_skip_verify: %{type: :boolean, required: false}
                },
                required: false
              },
              required: false
            },
            autostart: %{type: :boolean, required: false},
            autostop: %{type: :string, enum: {"off", "stop", "suspend"}, required: false},
            concurrency: %{
              type: :map,
              keys: %{
                type: %{type: :string, required: false},
                hard_limit: %{type: :integer, required: false},
                soft_limit: %{type: :integer, required: false}
              },
              required: false
            },
            force_instance_description: %{type: :string, required: false},
            force_instance_key: %{type: :string, required: false},
            internal_port: %{type: :integer, required: false},
            min_machines_running: %{type: :integer, required: false}
          },
          required: false
        },
        required: false
      },
      files: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            mode: %{type: :integer, required: false},
            guest_path: %{type: :string, required: false},
            raw_value: %{type: :string, required: false},
            secret_name: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      auto_destroy: %{type: :boolean, required: false},
      checks: %{type: :map, required: false},
      disable_machine_autostart: %{type: :boolean, required: false},
      guest: %{
        type: :map,
        keys: %{
          cpu_kind: %{type: :string, required: false},
          cpus: %{type: :integer, required: false},
          gpu_kind: %{type: :string, required: false},
          gpus: %{type: :integer, required: false},
          host_dedication_id: %{type: :string, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          memory_mb: %{type: :integer, required: false}
        },
        required: false
      },
      metrics: %{
        type: :map,
        keys: %{port: %{type: :integer, required: false}, path: %{type: :string, required: false}},
        required: false
      },
      mounts: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            name: %{type: :string, required: false},
            path: %{type: :string, required: false},
            add_size_gb: %{type: :integer, required: false},
            encrypted: %{type: :boolean, required: false},
            extend_threshold_percent: %{type: :integer, required: false},
            size_gb: %{type: :integer, required: false},
            size_gb_limit: %{type: :integer, required: false},
            volume: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      schedule: %{type: :string, required: false},
      standbys: %{type: :list, items: %{type: :string, required: false}, required: false},
      statics: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            guest_path: %{type: :string, required: false},
            index_document: %{type: :string, required: false},
            tigris_bucket: %{type: :string, required: false},
            url_prefix: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      stop_config: %{
        type: :map,
        keys: %{
          timeout: %{
            type: :map,
            keys: %{"time.Duration": %{type: :integer, required: false}},
            required: false
          },
          signal: %{type: :string, required: false}
        },
        required: false
      }
    },
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ErrorResponse do
  @schema %{
  error: %{type: :string, required: false},
  status: %{type: :string, enum: {"unknown", "insufficient_capacity"}, required: false},
  details: %{type: :map, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyTLSOptions do
  @schema %{
  versions: %{type: :list, items: %{type: :string, required: false}, required: false},
  alpn: %{type: :list, items: %{type: :string, required: false}, required: false},
  default_self_signed: %{type: :boolean, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineInit do
  @schema %{
  tty: %{type: :boolean, required: false},
  exec: %{type: :list, items: %{type: :string, required: false}, required: false},
  cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
  kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
  entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
  swap_size_mb: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyHTTPOptions do
  @schema %{
  compress: %{type: :boolean, required: false},
  response: %{
    type: :map,
    keys: %{headers: %{type: :map, required: false}, pristine: %{type: :boolean, required: false}},
    required: false
  },
  h2_backend: %{type: :boolean, required: false},
  headers_read_timeout: %{type: :integer, required: false},
  idle_timeout: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ListSecret do
  @schema %{
  label: %{type: :string, required: false},
  type: %{type: :string, required: false},
  publickey: %{type: :list, items: %{type: :integer, required: false}, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineServiceConcurrency do
  @schema %{
  type: %{type: :string, required: false},
  hard_limit: %{type: :integer, required: false},
  soft_limit: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineSecret do
  @schema %{name: %{type: :string, required: false}, env_var: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachinePort do
  @schema %{
  port: %{type: :integer, required: false},
  handlers: %{type: :list, items: %{type: :string, required: false}, required: false},
  start_port: %{type: :integer, required: false},
  http_options: %{
    type: :map,
    keys: %{
      compress: %{type: :boolean, required: false},
      response: %{
        type: :map,
        keys: %{
          headers: %{type: :map, required: false},
          pristine: %{type: :boolean, required: false}
        },
        required: false
      },
      h2_backend: %{type: :boolean, required: false},
      headers_read_timeout: %{type: :integer, required: false},
      idle_timeout: %{type: :integer, required: false}
    },
    required: false
  },
  end_port: %{type: :integer, required: false},
  force_https: %{type: :boolean, required: false},
  proxy_proto_options: %{
    type: :map,
    keys: %{version: %{type: :string, required: false}},
    required: false
  },
  tls_options: %{
    type: :map,
    keys: %{
      versions: %{type: :list, items: %{type: :string, required: false}, required: false},
      alpn: %{type: :list, items: %{type: :string, required: false}, required: false},
      default_self_signed: %{type: :boolean, required: false}
    },
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.Machine do
  @schema %{
  id: %{type: :string, required: false},
  name: %{type: :string, required: false},
  state: %{type: :string, required: false},
  config: %{
    type: :map,
    keys: %{
      env: %{type: :map, required: false},
      init: %{
        type: :map,
        keys: %{
          tty: %{type: :boolean, required: false},
          exec: %{type: :list, items: %{type: :string, required: false}, required: false},
          cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
          swap_size_mb: %{type: :integer, required: false}
        },
        required: false
      },
      processes: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            env: %{type: :map, required: false},
            user: %{type: :string, required: false},
            exec: %{type: :list, items: %{type: :string, required: false}, required: false},
            cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
            entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
            env_from: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  env_var: %{type: :string, required: false},
                  field_ref: %{
                    type: :string,
                    enum: {"id", "version", "app_name", "private_ip", "region", "image"},
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            ignore_app_secrets: %{type: :boolean, required: false},
            secrets: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  name: %{type: :string, required: false},
                  env_var: %{type: :string, required: false}
                },
                required: false
              },
              required: false
            }
          },
          required: false
        },
        required: false
      },
      restart: %{
        type: :map,
        keys: %{
          gpu_bid_price: %{type: :float, required: false},
          max_retries: %{type: :integer, required: false},
          policy: %{
            type: :string,
            enum: {"no", "always", "on-failure", "spot-price"},
            required: false
          }
        },
        required: false
      },
      size: %{type: :string, required: false},
      metadata: %{type: :map, required: false},
      image: %{type: :string, required: false},
      dns: %{
        type: :map,
        keys: %{
          options: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                name: %{type: :string, required: false},
                value: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          nameservers: %{type: :list, items: %{type: :string, required: false}, required: false},
          hostname: %{type: :string, required: false},
          dns_forward_rules: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                addr: %{type: :string, required: false},
                basename: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          hostname_fqdn: %{type: :string, required: false},
          searches: %{type: :list, items: %{type: :string, required: false}, required: false},
          skip_registration: %{type: :boolean, required: false}
        },
        required: false
      },
      services: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            ports: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  port: %{type: :integer, required: false},
                  handlers: %{
                    type: :list,
                    items: %{type: :string, required: false},
                    required: false
                  },
                  start_port: %{type: :integer, required: false},
                  http_options: %{
                    type: :map,
                    keys: %{
                      compress: %{type: :boolean, required: false},
                      response: %{
                        type: :map,
                        keys: %{
                          headers: %{type: :map, required: false},
                          pristine: %{type: :boolean, required: false}
                        },
                        required: false
                      },
                      h2_backend: %{type: :boolean, required: false},
                      headers_read_timeout: %{type: :integer, required: false},
                      idle_timeout: %{type: :integer, required: false}
                    },
                    required: false
                  },
                  end_port: %{type: :integer, required: false},
                  force_https: %{type: :boolean, required: false},
                  proxy_proto_options: %{
                    type: :map,
                    keys: %{version: %{type: :string, required: false}},
                    required: false
                  },
                  tls_options: %{
                    type: :map,
                    keys: %{
                      versions: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      alpn: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      default_self_signed: %{type: :boolean, required: false}
                    },
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            protocol: %{type: :string, required: false},
            checks: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  timeout: %{type: :map, required: false},
                  port: %{type: :integer, required: false},
                  type: %{type: :string, required: false},
                  path: %{type: :string, required: false},
                  protocol: %{type: :string, required: false},
                  interval: %{type: :map, required: false},
                  kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
                  headers: %{
                    type: :list,
                    items: %{
                      type: :map,
                      keys: %{
                        name: %{type: :string, required: false},
                        values: %{
                          type: :list,
                          items: %{type: :string, required: false},
                          required: false
                        }
                      },
                      required: false
                    },
                    required: false
                  },
                  grace_period: %{type: :map, required: false},
                  method: %{type: :string, required: false},
                  tls_server_name: %{type: :string, required: false},
                  tls_skip_verify: %{type: :boolean, required: false}
                },
                required: false
              },
              required: false
            },
            autostart: %{type: :boolean, required: false},
            autostop: %{type: :string, enum: {"off", "stop", "suspend"}, required: false},
            concurrency: %{
              type: :map,
              keys: %{
                type: %{type: :string, required: false},
                hard_limit: %{type: :integer, required: false},
                soft_limit: %{type: :integer, required: false}
              },
              required: false
            },
            force_instance_description: %{type: :string, required: false},
            force_instance_key: %{type: :string, required: false},
            internal_port: %{type: :integer, required: false},
            min_machines_running: %{type: :integer, required: false}
          },
          required: false
        },
        required: false
      },
      files: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            mode: %{type: :integer, required: false},
            guest_path: %{type: :string, required: false},
            raw_value: %{type: :string, required: false},
            secret_name: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      auto_destroy: %{type: :boolean, required: false},
      checks: %{type: :map, required: false},
      disable_machine_autostart: %{type: :boolean, required: false},
      guest: %{
        type: :map,
        keys: %{
          cpu_kind: %{type: :string, required: false},
          cpus: %{type: :integer, required: false},
          gpu_kind: %{type: :string, required: false},
          gpus: %{type: :integer, required: false},
          host_dedication_id: %{type: :string, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          memory_mb: %{type: :integer, required: false}
        },
        required: false
      },
      metrics: %{
        type: :map,
        keys: %{port: %{type: :integer, required: false}, path: %{type: :string, required: false}},
        required: false
      },
      mounts: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            name: %{type: :string, required: false},
            path: %{type: :string, required: false},
            add_size_gb: %{type: :integer, required: false},
            encrypted: %{type: :boolean, required: false},
            extend_threshold_percent: %{type: :integer, required: false},
            size_gb: %{type: :integer, required: false},
            size_gb_limit: %{type: :integer, required: false},
            volume: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      schedule: %{type: :string, required: false},
      standbys: %{type: :list, items: %{type: :string, required: false}, required: false},
      statics: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            guest_path: %{type: :string, required: false},
            index_document: %{type: :string, required: false},
            tigris_bucket: %{type: :string, required: false},
            url_prefix: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      stop_config: %{
        type: :map,
        keys: %{
          timeout: %{
            type: :map,
            keys: %{"time.Duration": %{type: :integer, required: false}},
            required: false
          },
          signal: %{type: :string, required: false}
        },
        required: false
      }
    },
    required: false
  },
  events: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        id: %{type: :string, required: false},
        status: %{type: :string, required: false},
        timestamp: %{type: :integer, required: false},
        type: %{type: :string, required: false},
        request: %{type: :map, required: false},
        source: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  updated_at: %{type: :string, required: false},
  checks: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        name: %{type: :string, required: false},
        output: %{type: :string, required: false},
        status: %{type: :string, required: false},
        updated_at: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  region: %{type: :string, required: false},
  created_at: %{type: :string, required: false},
  host_status: %{type: :string, enum: {"ok", "unknown", "unreachable"}, required: false},
  image_ref: %{
    type: :map,
    keys: %{
      tag: %{type: :string, required: false},
      registry: %{type: :string, required: false},
      labels: %{type: :map, required: false},
      repository: %{type: :string, required: false},
      digest: %{type: :string, required: false}
    },
    required: false
  },
  incomplete_config: %{
    type: :map,
    keys: %{
      env: %{type: :map, required: false},
      init: %{
        type: :map,
        keys: %{
          tty: %{type: :boolean, required: false},
          exec: %{type: :list, items: %{type: :string, required: false}, required: false},
          cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
          swap_size_mb: %{type: :integer, required: false}
        },
        required: false
      },
      processes: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            env: %{type: :map, required: false},
            user: %{type: :string, required: false},
            exec: %{type: :list, items: %{type: :string, required: false}, required: false},
            cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
            entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
            env_from: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  env_var: %{type: :string, required: false},
                  field_ref: %{
                    type: :string,
                    enum: {"id", "version", "app_name", "private_ip", "region", "image"},
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            ignore_app_secrets: %{type: :boolean, required: false},
            secrets: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  name: %{type: :string, required: false},
                  env_var: %{type: :string, required: false}
                },
                required: false
              },
              required: false
            }
          },
          required: false
        },
        required: false
      },
      restart: %{
        type: :map,
        keys: %{
          gpu_bid_price: %{type: :float, required: false},
          max_retries: %{type: :integer, required: false},
          policy: %{
            type: :string,
            enum: {"no", "always", "on-failure", "spot-price"},
            required: false
          }
        },
        required: false
      },
      size: %{type: :string, required: false},
      metadata: %{type: :map, required: false},
      image: %{type: :string, required: false},
      dns: %{
        type: :map,
        keys: %{
          options: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                name: %{type: :string, required: false},
                value: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          nameservers: %{type: :list, items: %{type: :string, required: false}, required: false},
          hostname: %{type: :string, required: false},
          dns_forward_rules: %{
            type: :list,
            items: %{
              type: :map,
              keys: %{
                addr: %{type: :string, required: false},
                basename: %{type: :string, required: false}
              },
              required: false
            },
            required: false
          },
          hostname_fqdn: %{type: :string, required: false},
          searches: %{type: :list, items: %{type: :string, required: false}, required: false},
          skip_registration: %{type: :boolean, required: false}
        },
        required: false
      },
      services: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            ports: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  port: %{type: :integer, required: false},
                  handlers: %{
                    type: :list,
                    items: %{type: :string, required: false},
                    required: false
                  },
                  start_port: %{type: :integer, required: false},
                  http_options: %{
                    type: :map,
                    keys: %{
                      compress: %{type: :boolean, required: false},
                      response: %{
                        type: :map,
                        keys: %{
                          headers: %{type: :map, required: false},
                          pristine: %{type: :boolean, required: false}
                        },
                        required: false
                      },
                      h2_backend: %{type: :boolean, required: false},
                      headers_read_timeout: %{type: :integer, required: false},
                      idle_timeout: %{type: :integer, required: false}
                    },
                    required: false
                  },
                  end_port: %{type: :integer, required: false},
                  force_https: %{type: :boolean, required: false},
                  proxy_proto_options: %{
                    type: :map,
                    keys: %{version: %{type: :string, required: false}},
                    required: false
                  },
                  tls_options: %{
                    type: :map,
                    keys: %{
                      versions: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      alpn: %{
                        type: :list,
                        items: %{type: :string, required: false},
                        required: false
                      },
                      default_self_signed: %{type: :boolean, required: false}
                    },
                    required: false
                  }
                },
                required: false
              },
              required: false
            },
            protocol: %{type: :string, required: false},
            checks: %{
              type: :list,
              items: %{
                type: :map,
                keys: %{
                  timeout: %{type: :map, required: false},
                  port: %{type: :integer, required: false},
                  type: %{type: :string, required: false},
                  path: %{type: :string, required: false},
                  protocol: %{type: :string, required: false},
                  interval: %{type: :map, required: false},
                  kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
                  headers: %{
                    type: :list,
                    items: %{
                      type: :map,
                      keys: %{
                        name: %{type: :string, required: false},
                        values: %{
                          type: :list,
                          items: %{type: :string, required: false},
                          required: false
                        }
                      },
                      required: false
                    },
                    required: false
                  },
                  grace_period: %{type: :map, required: false},
                  method: %{type: :string, required: false},
                  tls_server_name: %{type: :string, required: false},
                  tls_skip_verify: %{type: :boolean, required: false}
                },
                required: false
              },
              required: false
            },
            autostart: %{type: :boolean, required: false},
            autostop: %{type: :string, enum: {"off", "stop", "suspend"}, required: false},
            concurrency: %{
              type: :map,
              keys: %{
                type: %{type: :string, required: false},
                hard_limit: %{type: :integer, required: false},
                soft_limit: %{type: :integer, required: false}
              },
              required: false
            },
            force_instance_description: %{type: :string, required: false},
            force_instance_key: %{type: :string, required: false},
            internal_port: %{type: :integer, required: false},
            min_machines_running: %{type: :integer, required: false}
          },
          required: false
        },
        required: false
      },
      files: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            mode: %{type: :integer, required: false},
            guest_path: %{type: :string, required: false},
            raw_value: %{type: :string, required: false},
            secret_name: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      auto_destroy: %{type: :boolean, required: false},
      checks: %{type: :map, required: false},
      disable_machine_autostart: %{type: :boolean, required: false},
      guest: %{
        type: :map,
        keys: %{
          cpu_kind: %{type: :string, required: false},
          cpus: %{type: :integer, required: false},
          gpu_kind: %{type: :string, required: false},
          gpus: %{type: :integer, required: false},
          host_dedication_id: %{type: :string, required: false},
          kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
          memory_mb: %{type: :integer, required: false}
        },
        required: false
      },
      metrics: %{
        type: :map,
        keys: %{port: %{type: :integer, required: false}, path: %{type: :string, required: false}},
        required: false
      },
      mounts: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            name: %{type: :string, required: false},
            path: %{type: :string, required: false},
            add_size_gb: %{type: :integer, required: false},
            encrypted: %{type: :boolean, required: false},
            extend_threshold_percent: %{type: :integer, required: false},
            size_gb: %{type: :integer, required: false},
            size_gb_limit: %{type: :integer, required: false},
            volume: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      schedule: %{type: :string, required: false},
      standbys: %{type: :list, items: %{type: :string, required: false}, required: false},
      statics: %{
        type: :list,
        items: %{
          type: :map,
          keys: %{
            guest_path: %{type: :string, required: false},
            index_document: %{type: :string, required: false},
            tigris_bucket: %{type: :string, required: false},
            url_prefix: %{type: :string, required: false}
          },
          required: false
        },
        required: false
      },
      stop_config: %{
        type: :map,
        keys: %{
          timeout: %{
            type: :map,
            keys: %{"time.Duration": %{type: :integer, required: false}},
            required: false
          },
          signal: %{type: :string, required: false}
        },
        required: false
      }
    },
    required: false
  },
  instance_id: %{type: :string, required: false},
  nonce: %{type: :string, required: false},
  private_ip: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineHTTPHeader do
  @schema %{
  name: %{type: :string, required: false},
  values: %{type: :list, items: %{type: :string, required: false}, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.main.statusCode do
  @schema %{type: :string, enum: {"unknown", "insufficient_capacity"}, required: false}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateOIDCTokenRequest do
  @schema %{aud: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineGuest do
  @schema %{
  cpu_kind: %{type: :string, required: false},
  cpus: %{type: :integer, required: false},
  gpu_kind: %{type: :string, required: false},
  gpus: %{type: :integer, required: false},
  host_dedication_id: %{type: :string, required: false},
  kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
  memory_mb: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.Organization do
  @schema %{name: %{type: :string, required: false}, slug: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.UpdateMachineRequest do
  @schema %{
  name: %{type: :string, required: false},
  config: %{type: :map, required: false},
  lease_ttl: %{type: :integer, required: false},
  lsvd: %{type: :boolean, required: false},
  region: %{type: :string, required: false},
  skip_launch: %{type: :boolean, required: false},
  skip_service_registration: %{type: :boolean, required: false},
  current_version: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyStopConfig do
  @schema %{
  timeout: %{
    type: :map,
    keys: %{"time.Duration": %{type: :integer, required: false}},
    required: false
  },
  signal: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineMount do
  @schema %{
  name: %{type: :string, required: false},
  path: %{type: :string, required: false},
  add_size_gb: %{type: :integer, required: false},
  encrypted: %{type: :boolean, required: false},
  extend_threshold_percent: %{type: :integer, required: false},
  size_gb: %{type: :integer, required: false},
  size_gb_limit: %{type: :integer, required: false},
  volume: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineMetrics do
  @schema %{port: %{type: :integer, required: false}, path: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateLeaseRequest do
  @schema %{ttl: %{type: :integer, required: false}, description: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ExtendVolumeRequest do
  @schema %{size_gb: %{type: :integer, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.MachineExecRequest do
  @schema %{
  timeout: %{type: :integer, required: false},
  command: %{type: :list, items: %{type: :string, required: false}, required: false},
  cmd: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.Lease do
  @schema %{
  owner: %{type: :string, required: false},
  version: %{type: :string, required: false},
  description: %{type: :string, required: false},
  nonce: %{type: :string, required: false},
  expires_at: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlydnsOption do
  @schema %{name: %{type: :string, required: false}, value: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.App do
  @schema %{
  id: %{type: :string, required: false},
  name: %{type: :string, required: false},
  status: %{type: :string, required: false},
  organization: %{
    type: :map,
    keys: %{name: %{type: :string, required: false}, slug: %{type: :string, required: false}},
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.StopRequest do
  @schema %{
  timeout: %{
    type: :map,
    keys: %{"time.Duration": %{type: :integer, required: false}},
    required: false
  },
  signal: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.UpdateVolumeRequest do
  @schema %{
  auto_backup_enabled: %{type: :boolean, required: false},
  snapshot_retention: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineService do
  @schema %{
  ports: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        port: %{type: :integer, required: false},
        handlers: %{type: :list, items: %{type: :string, required: false}, required: false},
        start_port: %{type: :integer, required: false},
        http_options: %{
          type: :map,
          keys: %{
            compress: %{type: :boolean, required: false},
            response: %{
              type: :map,
              keys: %{
                headers: %{type: :map, required: false},
                pristine: %{type: :boolean, required: false}
              },
              required: false
            },
            h2_backend: %{type: :boolean, required: false},
            headers_read_timeout: %{type: :integer, required: false},
            idle_timeout: %{type: :integer, required: false}
          },
          required: false
        },
        end_port: %{type: :integer, required: false},
        force_https: %{type: :boolean, required: false},
        proxy_proto_options: %{
          type: :map,
          keys: %{version: %{type: :string, required: false}},
          required: false
        },
        tls_options: %{
          type: :map,
          keys: %{
            versions: %{type: :list, items: %{type: :string, required: false}, required: false},
            alpn: %{type: :list, items: %{type: :string, required: false}, required: false},
            default_self_signed: %{type: :boolean, required: false}
          },
          required: false
        }
      },
      required: false
    },
    required: false
  },
  protocol: %{type: :string, required: false},
  checks: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        timeout: %{type: :map, required: false},
        port: %{type: :integer, required: false},
        type: %{type: :string, required: false},
        path: %{type: :string, required: false},
        protocol: %{type: :string, required: false},
        interval: %{type: :map, required: false},
        kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
        headers: %{
          type: :list,
          items: %{
            type: :map,
            keys: %{
              name: %{type: :string, required: false},
              values: %{type: :list, items: %{type: :string, required: false}, required: false}
            },
            required: false
          },
          required: false
        },
        grace_period: %{type: :map, required: false},
        method: %{type: :string, required: false},
        tls_server_name: %{type: :string, required: false},
        tls_skip_verify: %{type: :boolean, required: false}
      },
      required: false
    },
    required: false
  },
  autostart: %{type: :boolean, required: false},
  autostop: %{type: :string, enum: {"off", "stop", "suspend"}, required: false},
  concurrency: %{
    type: :map,
    keys: %{
      type: %{type: :string, required: false},
      hard_limit: %{type: :integer, required: false},
      soft_limit: %{type: :integer, required: false}
    },
    required: false
  },
  force_instance_description: %{type: :string, required: false},
  force_instance_key: %{type: :string, required: false},
  internal_port: %{type: :integer, required: false},
  min_machines_running: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineProcess do
  @schema %{
  env: %{type: :map, required: false},
  user: %{type: :string, required: false},
  exec: %{type: :list, items: %{type: :string, required: false}, required: false},
  cmd: %{type: :list, items: %{type: :string, required: false}, required: false},
  entrypoint: %{type: :list, items: %{type: :string, required: false}, required: false},
  env_from: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        env_var: %{type: :string, required: false},
        field_ref: %{
          type: :string,
          enum: {"id", "version", "app_name", "private_ip", "region", "image"},
          required: false
        }
      },
      required: false
    },
    required: false
  },
  ignore_app_secrets: %{type: :boolean, required: false},
  secrets: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{name: %{type: :string, required: false}, env_var: %{type: :string, required: false}},
      required: false
    },
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineCheck do
  @schema %{
  timeout: %{type: :map, required: false},
  port: %{type: :integer, required: false},
  type: %{type: :string, required: false},
  path: %{type: :string, required: false},
  protocol: %{type: :string, required: false},
  interval: %{type: :map, required: false},
  kind: %{type: :string, enum: {"informational", "readiness"}, required: false},
  headers: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        name: %{type: :string, required: false},
        values: %{type: :list, items: %{type: :string, required: false}, required: false}
      },
      required: false
    },
    required: false
  },
  grace_period: %{type: :map, required: false},
  method: %{type: :string, required: false},
  tls_server_name: %{type: :string, required: false},
  tls_skip_verify: %{type: :boolean, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyProxyProtoOptions do
  @schema %{version: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyFile do
  @schema %{
  mode: %{type: :integer, required: false},
  guest_path: %{type: :string, required: false},
  raw_value: %{type: :string, required: false},
  secret_name: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ListAppsResponse do
  @schema %{
  apps: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        id: %{type: :string, required: false},
        name: %{type: :string, required: false},
        machine_count: %{type: :integer, required: false},
        network: %{type: :map, required: false}
      },
      required: false
    },
    required: false
  },
  total_apps: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyMachineRestart do
  @schema %{
  gpu_bid_price: %{type: :float, required: false},
  max_retries: %{type: :integer, required: false},
  policy: %{type: :string, enum: {"no", "always", "on-failure", "spot-price"}, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateAppRequest do
  @schema %{
  network: %{type: :string, required: false},
  app_name: %{type: :string, required: false},
  enable_subdomains: %{type: :boolean, required: false},
  org_slug: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyEnvFrom do
  @schema %{
  env_var: %{type: :string, required: false},
  field_ref: %{
    type: :string,
    enum: {"id", "version", "app_name", "private_ip", "region", "image"},
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.SignalRequest do
  @schema %{
  signal: %{
    type: :string,
    enum:
      {"SIGABRT", "SIGALRM", "SIGFPE", "SIGHUP", "SIGILL", "SIGINT", "SIGKILL", "SIGPIPE",
       "SIGQUIT", "SIGSEGV", "SIGTERM", "SIGTRAP", "SIGUSR1"},
    required: false
  }
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.VolumeSnapshot do
  @schema %{
  id: %{type: :string, required: false},
  size: %{type: :integer, required: false},
  status: %{type: :string, required: false},
  digest: %{type: :string, required: false},
  created_at: %{type: :string, required: false},
  retention_days: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyStatic do
  @schema %{
  guest_path: %{type: :string, required: true},
  index_document: %{type: :string, required: false},
  tigris_bucket: %{type: :string, required: false},
  url_prefix: %{type: :string, required: true}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlydnsForwardRule do
  @schema %{addr: %{type: :string, required: false}, basename: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.MachineEvent do
  @schema %{
  id: %{type: :string, required: false},
  status: %{type: :string, required: false},
  timestamp: %{type: :integer, required: false},
  type: %{type: :string, required: false},
  request: %{type: :map, required: false},
  source: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyDNSConfig do
  @schema %{
  options: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{name: %{type: :string, required: false}, value: %{type: :string, required: false}},
      required: false
    },
    required: false
  },
  nameservers: %{type: :list, items: %{type: :string, required: false}, required: false},
  hostname: %{type: :string, required: false},
  dns_forward_rules: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        addr: %{type: :string, required: false},
        basename: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  hostname_fqdn: %{type: :string, required: false},
  searches: %{type: :list, items: %{type: :string, required: false}, required: false},
  skip_registration: %{type: :boolean, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ListApp do
  @schema %{
  id: %{type: :string, required: false},
  name: %{type: :string, required: false},
  machine_count: %{type: :integer, required: false},
  network: %{type: :map, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ProcessStat do
  @schema %{
  command: %{type: :string, required: false},
  cpu: %{type: :integer, required: false},
  pid: %{type: :integer, required: false},
  directory: %{type: :string, required: false},
  listen_sockets: %{
    type: :list,
    items: %{
      type: :map,
      keys: %{
        address: %{type: :string, required: false},
        proto: %{type: :string, required: false}
      },
      required: false
    },
    required: false
  },
  rss: %{type: :integer, required: false},
  rtime: %{type: :integer, required: false},
  stime: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ListenSocket do
  @schema %{address: %{type: :string, required: false}, proto: %{type: :string, required: false}}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ExtendVolumeResponse do
  @schema %{
  volume: %{
    type: :map,
    keys: %{
      id: %{type: :string, required: false},
      name: %{type: :string, required: false},
      state: %{type: :string, required: false},
      blocks: %{type: :integer, required: false},
      block_size: %{type: :integer, required: false},
      encrypted: %{type: :boolean, required: false},
      size_gb: %{type: :integer, required: false},
      region: %{type: :string, required: false},
      created_at: %{type: :string, required: false},
      host_status: %{type: :string, enum: {"ok", "unknown", "unreachable"}, required: false},
      auto_backup_enabled: %{type: :boolean, required: false},
      snapshot_retention: %{type: :integer, required: false},
      attached_alloc_id: %{type: :string, required: false},
      attached_machine_id: %{type: :string, required: false},
      blocks_avail: %{type: :integer, required: false},
      blocks_free: %{type: :integer, required: false},
      fstype: %{type: :string, required: false},
      zone: %{type: :string, required: false}
    },
    required: false
  },
  needs_restart: %{type: :boolean, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.CreateVolumeRequest do
  @schema %{
  name: %{type: :string, required: false},
  encrypted: %{type: :boolean, required: false},
  size_gb: %{type: :integer, required: false},
  region: %{type: :string, required: false},
  snapshot_retention: %{type: :integer, required: false},
  fstype: %{type: :string, required: false},
  compute: %{
    type: :map,
    keys: %{
      cpu_kind: %{type: :string, required: false},
      cpus: %{type: :integer, required: false},
      gpu_kind: %{type: :string, required: false},
      gpus: %{type: :integer, required: false},
      host_dedication_id: %{type: :string, required: false},
      kernel_args: %{type: :list, items: %{type: :string, required: false}, required: false},
      memory_mb: %{type: :integer, required: false}
    },
    required: false
  },
  compute_image: %{type: :string, required: false},
  require_unique_zone: %{type: :boolean, required: false},
  snapshot_id: %{type: :string, required: false},
  source_volume_id: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.Volume do
  @schema %{
  id: %{type: :string, required: false},
  name: %{type: :string, required: false},
  state: %{type: :string, required: false},
  blocks: %{type: :integer, required: false},
  block_size: %{type: :integer, required: false},
  encrypted: %{type: :boolean, required: false},
  size_gb: %{type: :integer, required: false},
  region: %{type: :string, required: false},
  created_at: %{type: :string, required: false},
  host_status: %{type: :string, enum: {"ok", "unknown", "unreachable"}, required: false},
  auto_backup_enabled: %{type: :boolean, required: false},
  snapshot_retention: %{type: :integer, required: false},
  attached_alloc_id: %{type: :string, required: false},
  attached_machine_id: %{type: :string, required: false},
  blocks_avail: %{type: :integer, required: false},
  blocks_free: %{type: :integer, required: false},
  fstype: %{type: :string, required: false},
  zone: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.flydv1.ExecResponse do
  @schema %{
  exit_signal: %{type: :integer, required: false},
  stdout: %{type: :string, required: false},
  stderr: %{type: :string, required: false},
  exit_code: %{type: :integer, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.ImageRef do
  @schema %{
  tag: %{type: :string, required: false},
  registry: %{type: :string, required: false},
  labels: %{type: :map, required: false},
  repository: %{type: :string, required: false},
  digest: %{type: :string, required: false}
}

  def schema, do: @schema
end


defmodule FlyMachinesApi.Schemas.FlyHTTPResponseOptions do
  @schema %{headers: %{type: :map, required: false}, pristine: %{type: :boolean, required: false}}

  def schema, do: @schema
end
