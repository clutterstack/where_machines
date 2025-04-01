defmodule WhereMachinesWeb.Router do
  use WhereMachinesWeb, :router
  # import WhereMachines.Plugs.RateLimit

  pipeline :browser do
    plug :accepts, ["html"]
    plug WhereMachines.Plugs.RateLimit,
    max_requests: 20,  # Default limit: 60 per minute
    path_limits: %{
      ~r{^/} => 5,          # Home page
      ~r{^\/[^\/]+$} => 10, # path for redirects to a specific machine
    }
    plug :fetch_session
    plug :fly_region_header_to_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WhereMachinesWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WhereMachinesWeb do
    pipe_through :browser
    # get "/", PageController, :home
    live "/", IndexLive
    get "/machine/:mach_id", RedirectController, :redirect_to_machine
  end

  # Other scopes may use custom stacks.
  # TODO: make /api 6pn only -- put it on a different port
  scope "/api", WhereMachinesWeb do
    pipe_through :api
    post "/machine_status", APIController, :update
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:where_machines, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WhereMachinesWeb.Telemetry
    end
  end

  def fly_region_header_to_session(conn, _opts) do
    header = get_req_header(conn, "fly-region")
    conn |> put_session(:fly_region, header)
  end
end
