require 'net/http'
require 'nokogiri'
require_relative 'XmlParseError'
require_relative 'GeoPoint'
require_relative 'RkGpxLogger'

class GeoCoder
  def initialize(log)
    @log = log
  end

  def address(geopoint)
    raise ArgumentError.new('Argument of "address" method must be GeoPoint') unless geopoint.kind_of? GeoPoint

    response = Net::HTTP.get_response("maps.googleapis.com", "/maps/api/geocode/xml?latlng=#{geopoint.lat},#{geopoint.lon}&sensor=false")

    raise IOError.new("Error with downloading geodata from Google API") unless response.code=="200"

    doc = Nokogiri::XML(response.body) do |config|
      config.default_xml.noblanks
    end

    unless doc.errors.empty?
      msg = String.new "Encountered problems during XML parsing. Output XML file might not be valid.\n #{doc.errors.last}"
      raise XmlParseError.new(msg)
    end

    xpath_street="/GeocodeResponse/result/address_component/type[contains(text(),'route')]/../long_name/text()[1]"
    xpath_town="(/GeocodeResponse/result/address_component/long_name/text()[../../type[text() = 'locality']][../../type[text() = 'political']])[1]"

    street = doc.xpath(xpath_street).to_s
    town = doc.xpath(xpath_town).to_s

    if street.empty?
      if town.empty?
        return nil
      else
        return town
      end
    end

    if town.empty?
      return street
    end

    return "#{street}, #{town}"
  end
end