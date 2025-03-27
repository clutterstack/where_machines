defmodule WhereMachines.CityData do

  @cities %{
    AMS: {5,52},
    IAD: {-77,39},
    ATL: {-84,34},
    BOG: {-74,5},
    BOS: {-71,42},
    OTP: {26,45},
    ORD: {-88,42},
    DFW: {-97,33},
    DEN: {-105,40},
    EZE: {-59,-35},
    ZRB: {9,50},
    GDL: {-103,21},
    HKG: {114,22},
    JNB: {28,-26},
    LHR: {0,51},
    LAX: {-118,34},
    MAD: {-4,40},
    MIA: {-80,26},
    YUL: {-74,45},
    BOM: {73,19},
    CDG: {3,49},
    PHX: {-112,33},
    QRO: {-100,21},
    GIG: {-43,-23},
    SJC: {-122,37},
    SCL: {-71,-33},
    GRU: {-46,-23},
    SEA: {-122,47},
    EWR: {-74,41},
    SIN: {104,1},
    ARN: {18,60},
    SYD: {151,-34},
    NRT: {140,36},
    YYZ: {-80,44},
    WAW: {21,52}
    }

def city_to_svg(city, bbox) do
  IO.inspect(city, label: "city")
  {long, lat} = @cities[city]
  latlong_to_svg({long, lat}, bbox)
end


def latlong_to_svg({long, lat}, {x_min, y_min, x_max, y_max}) do
  svg_width = x_max - x_min
  svg_height = y_max - y_min

   # Standard Mercator projection
   x = (long + 180) * (svg_width / 360)

   # Convert latitude to y coordinate using Mercator formula
   lat_rad = lat * :math.pi() / 180
   merc_n = :math.log(:math.tan((:math.pi() / 4) + (lat_rad / 2)))
   y = svg_height / 2 - (svg_width * merc_n / (2 * :math.pi()))

   {x, y}

    # # Calculate x position (longitude)
    # x = (long / 360)*(x_max-x_min) |> dbg

    # # Calculate y position (latitude) - note the inversion for SVG
    # y = (1 - (lat/ 90))*(y_max-y_min)/2 |> dbg

  end
end
