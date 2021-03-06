
module Gps

# haversine.rb
#
# haversine formula to compute the great circle distance between two points given their latitude and longitudes
#
# Copyright (C) 2008, 360VL, Inc
# Copyright (C) 2008, Landon Cox
#
# http://www.esawdust.com (Landon Cox)
# contact:
# http://www.esawdust.com/blog/businesscard/businesscard.html
#
# LICENSE: GNU Affero GPL v3
# The ruby implementation of the Haversine formula is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3 as published by the Free Software Foundation.  
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public 
# License version 3 for more details.  http://www.gnu.org/licenses/
#
# Landon Cox - 9/25/08
# 
# Notes:
#
# translated into Ruby based on information contained in:
#   http://mathforum.org/library/drmath/view/51879.html  Doctors Rick and Peterson - 4/20/99
#   http://www.movable-type.co.uk/scripts/latlong.html
#   http://en.wikipedia.org/wiki/Haversine_formula
#
# This formula can compute accurate distances between two points given latitude and longitude, even for 
# short distances.

# PI = 3.1415926535
  RAD_PER_DEG = 0.017453293  #  PI/180

  # the great circle distance d will be in whatever units R is in

  Gps::Rmiles = 3956           # radius of the great circle in miles
  Gps::Rkm = 6371              # radius in kilometers...some algorithms use 6367
  Gps::Rfeet = Rmiles * 5282   # radius in feet
  Gps::Rmeters = Rkm * 1000    # radius in meters

          # sense to new a Hash each time over potentially 100's of thousands of points

=begin rdoc
  given two lat/lon points, compute the distance between the two points using the haversine formula
  the result will be a Hash of distances which are key'd by 'mi','km','ft', and 'm'
=end
  def distance( p1, p2 )
    @distances = Hash.new

    lat1 = p1.lat
    lon1 = p1.lon
    lat2 = p2.lat
    lon2 = p2.lon

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lat2_rad = lat2 * RAD_PER_DEG

    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

    dMi = Gps::Rmiles * c          # delta between the two points in miles
    dKm = Gps::Rkm * c             # delta in kilometers
    dFeet = Gps::Rfeet * c         # delta in feet
    dMeters = Gps::Rmeters * c     # delta in meters

    @distances["mi"] = dMi
    @distances["km"] = dKm
    @distances["ft"] = dFeet
    @distances["m"] = dMeters

    @distances
  end

end