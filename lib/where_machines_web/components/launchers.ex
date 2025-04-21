defmodule WhereMachinesWeb.Launchers do
  use Phoenix.Component

  require Logger

  def launcher(%{variant: :single} = assigns) do
    ~H"""
    <!-- Create Machine Button -->
    <div class="panel col-span-3">
      <div>Push button to create your Useless Machine in the cloud</div>
      <div class="text-2xl">START</div>

        <!-- Machine Launcher Component with button -->
        <.live_component
          module={WhereMachinesWeb.MachineLauncher}
          id="local-button"
          regions={[:local]}
          classes="relative rounded-full border-2 border-zinc-700 w-20 h-20 flex justify-center items-center"
          btn_class="absolute
                  w-16 h-16 rounded-full
                  border border-[#DAA520]
                  text-transparent
                  cursor-pointer z-10
                  shadow-lg
                  hover:shadow-xl
                  active:scale-95
                  transition-all
                  duration-300"
        ></.live_component>
    </div>
    """
  end

  def launcher(%{variant: :all_regions} = assigns) do
    ~H"""
     <!-- Machine Launcher Component with buttons -->
      <.live_component
        module={WhereMachinesWeb.MachineLauncher}
        id="machine-launcher"
        regions={assigns.regions}
        classes="col-span-4 button-grid"
        btn_class="dash-button"
      ></.live_component>
    """
  end

end
