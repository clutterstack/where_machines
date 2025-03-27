defmodule WhereMachinesWeb.DesignOld do
  use Phoenix.Component

  # Render the world map SVG
  def world_map_svg(assigns) do
    ~H"""
    <svg class="w-full h-full" viewBox="0 0 1000 600" xmlns="http://www.w3.org/2000/svg">
      <!-- Background and grid lines -->
      <rect width="1000" height="600" fill="#1f1f23" />
      <path d="M0,100 L1000,100 M0,200 L1000,200 M0,300 L1000,300 M0,400 L1000,400 M0,500 L1000,500 M100,0 L100,600 M200,0 L200,600 M300,0 L300,600 M400,0 L400,600 M500,0 L500,600 M600,0 L600,600 M700,0 L700,600 M800,0 L800,600 M900,0 L900,600" stroke="#333" stroke-width="1" />

      <!-- Stylized continents -->
      <path d="M120,180 Q170,150 220,190 T320,210 Q350,180 390,220 T450,180 Q480,220 540,200 T600,220 Q650,180 700,220 T800,180" fill="none" stroke="#e6bc2f" stroke-width="3" opacity="0.7" />

      <!-- North America stylized -->
      <path d="M150,200 Q200,180 240,220 T270,180 T320,200" fill="none" stroke="#e6bc2f" stroke-width="2" opacity="0.8" />

      <!-- Europe stylized -->
      <path d="M450,200 Q470,180 500,190 T530,180 T560,200" fill="none" stroke="#e6bc2f" stroke-width="2" opacity="0.8" />

      <!-- Asia stylized -->
      <path d="M550,210 Q600,180 650,200 T700,180 T750,210" fill="none" stroke="#e6bc2f" stroke-width="2" opacity="0.8" />

      <!-- Australia stylized -->
      <path d="M780,330 Q800,310 820,330 T840,310 T860,330" fill="none" stroke="#e6bc2f" stroke-width="2" opacity="0.8" />

      <!-- Machine indicators based on regions -->
      <circle cx="200" cy="200" r="10" fill="#e6bc2f" opacity="0.9">
        <title>YYZ - Toronto</title>
        <animate attributeName="r" values="10;12;10" dur="3s" repeatCount="indefinite" />
      </circle>

      <circle cx="150" cy="240" r="10" fill="#e6bc2f" opacity="0.9">
        <title>LAX - Los Angeles</title>
        <animate attributeName="r" values="10;12;10" dur="3s" repeatCount="indefinite" />
      </circle>

      <circle cx="500" cy="190" r="10" fill="#e6bc2f" opacity="0.9">
        <title>AMS - Amsterdam</title>
        <animate attributeName="r" values="10;12;10" dur="3s" repeatCount="indefinite" />
      </circle>

      <circle cx="800" cy="320" r="10" fill="#e6bc2f" opacity="0.9">
        <title>SYD - Sydney</title>
        <animate attributeName="r" values="10;12;10" dur="3s" repeatCount="indefinite" />
      </circle>

      <!-- Connection lines between machines -->
      <path d="M200,200 Q400,100 500,190" fill="none" stroke="#e6bc2f" stroke-width="1" opacity="0.4">
        <animate attributeName="opacity" values="0.4;0.7;0.4" dur="4s" repeatCount="indefinite" />
      </path>

      <path d="M150,240 Q400,300 500,190" fill="none" stroke="#e6bc2f" stroke-width="1" opacity="0.4">
        <animate attributeName="opacity" values="0.4;0.7;0.4" dur="5s" repeatCount="indefinite" />
      </path>

      <path d="M500,190 Q650,250 800,320" fill="none" stroke="#e6bc2f" stroke-width="1" opacity="0.4">
        <animate attributeName="opacity" values="0.4;0.7;0.4" dur="6s" repeatCount="indefinite" />
      </path>
    </svg>
    """
  end

end
