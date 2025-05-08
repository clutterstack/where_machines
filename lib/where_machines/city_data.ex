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
    fra: {9,50},
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
    waw: {21,52},
    unknown: {0,0}
    }
    @short %{
      ams: "Amsterdam",
      iad: "Ashburn",
      atl: "Atlanta" ,
      bog: "Bogotá",
      bos: "Boston",
      otp: "Bucharest",
      ord: "Chicago",
      dfw: "Dallas",
      den: "Denver",
      eze: "Ezeiza",
      fra: "Frankfurt",
      gdl: "Guadalajara",
      hkg: "Hong Kong",
      jnb: "Johannesburg",
      lhr: "London",
      lax: "Los Angeles",
      mad: "Madrid",
      mia: "Miami",
      yul: "Montreal",
      bom: "Mumbai",
      cdg: "Paris",
      phx: "Phoenix",
      qro: "Querétaro",
      gig: "Rio de Janeiro",
      sjc: "San Jose",
      scl: "Santiago",
      gru: "Sao Paulo",
      sea: "Seattle",
      ewr: "Secaucus",
      sin: "Singapore",
      arn: "Stockholm",
      syd: "Sydney",
      nrt: "Tokyo",
      yyz: "Toronto",
      waw: "Warsaw"
    }


  def short([]) do
    "your computer"
  end

  def short(region_code) do
    key = String.to_existing_atom(region_code)
    @short[key]
  end

  def cities do
    @cities
  end

end
