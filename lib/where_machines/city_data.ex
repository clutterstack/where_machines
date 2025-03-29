defmodule WhereMachines.CityData do

  @cities %{
    ams: {5,52},
    iad: {-77,39},
    atl: {-84,34},
    bog: {-74,5},
    bos: {-71,42},
    otp: {26,45},
    ord: {-88,42},
    dfw: {-97,33},
    den: {-105,40},
    eze: {-59,-35},
    zrb: {9,50},
    gdl: {-103,21},
    hkg: {114,22},
    jnb: {28,-26},
    lhr: {0,51},
    lax: {-118,34},
    mad: {-4,40},
    mia: {-80,26},
    yul: {-74,45},
    bom: {73,19},
    cdg: {3,49},
    phx: {-112,33},
    qro: {-100,21},
    gig: {-43,-23},
    sjc: {-122,37},
    scl: {-71,-33},
    gru: {-46,-23},
    sea: {-122,47},
    ewr: {-74,41},
    sin: {104,1},
    arn: {18,60},
    syd: {151,-34},
    nrt: {140,36},
    yyz: {-80,44},
    waw: {21,52}
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
