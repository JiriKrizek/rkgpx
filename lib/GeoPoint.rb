class GeoPoint
  attr_accessor :lat, :lon
  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def to_s
    "#{lat},#{lon}"
  end
end