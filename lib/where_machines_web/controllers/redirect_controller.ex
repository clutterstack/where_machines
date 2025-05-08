defmodule WhereMachinesWeb.RedirectController do
  use WhereMachinesWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  # def redirect_to_machine(conn, %{"mach_id" => mach_id}) do
  #   IO.puts("about to respond with fly-replay header")
  #   # Process.sleep(5000)  # 5 second delay
  #   conn
  #   |> put_resp_header("fly-replay", "app=useless-machine;instance=#{mach_id}")
  #   |> send_resp(200, "Forwarding")
  # end

end
