class Address < ActiveRecord::Base
  require 'httparty'
  require 'json'
  require 'easting_northing'
  require 'pat'

  def latlng
    latlng = EastingNorthing.eastingNorthingToLatLong(self.x, self.y)
    results = Hash.new
    results[:lat] = latlng["lat"]
    results[:lng] = latlng["long"]
    return results
  end

  def self.address_endpoint(query, layer = "POSTCODE")
    "http://gis.lichfielddc.gov.uk/arcgis/rest/services/PUBLIC/County_NLPG/MapServer/find?searchText=#{query}&contains=true&layers=#{layer}&returnGeometry=true&f=pjson"
  end

  def self.coerce_address(address)
    address.each { |k,v| address[k] = nil if v == "Null" }
    address
  end

  def self.first_line(address)
    sao = addressable_object(address, "SAO")
    pao = addressable_object(address, "PAO")
    [
      address["SAO_TEXT"], sao, address["PAO_TEXT"], pao, address["STREET_DESCRIPTOR"]
    ].reject!{ |p| p.blank? }.join(" ")
  end

  def self.full_address(address)
    [
      address["FIRST_LINE"], address["LOCALITY_NAME"], address["POST_TOWN"], address["POSTCODE"]
    ].reject { |p| p.blank?}.join(", ")
  end

  def self.addressable_object(address, type)
    s = address["#{type}_START_NUMBER"].to_s + address["#{type}_START_SUFFIX"].to_s
    e = address["#{type}_END_NUMBER"].to_s + address["#{type}_END_SUFFIX"].to_s
    if s.blank? && e.blank?
      nil
    elsif e.blank?
      s
    else
      "#{s} - #{e}"
    end
  end

	def self.build_address(item)
		address = coerce_address(item["attributes"])
		address["FIRST_LINE"] = first_line(address)

		result = Hash.new
		result[:uprn] = address["UPRN"].to_i
		result[:address] = full_address(address)
		result[:address1] = address["FIRST_LINE"]
		result[:address2] = address["LOCALITY_NAME"]
		result[:address3] = nil
		result[:address4] = nil
		result[:town] = address["POST_TOWN"]
		result[:postcode] = address["POSTCODE"]
		result[:easting] = item["geometry"]["x"].to_i
		result[:northing] = item["geometry"]["y"].to_i

		easting = item["geometry"]["x"].to_i
		northing = item["geometry"]["y"].to_i

		latlng = EastingNorthing.eastingNorthingToLatLong(easting, northing)

		result[:lat] = latlng["lat"]
		result[:lng] = latlng["long"]

		result
	end

  def self.GetAddressFromPostcode(postcode)
    postcode = CGI::escape(postcode)
    url = address_endpoint(postcode)

    addresses = JSON.parse HTTParty.get(url).response.body

    num = 0
    results = []

    addresses["results"].each do |item|
			results[num] = build_address(item)
      num += 1
    end

    return results.uniq! { |a| a[:address] }.sort_by { |a| a[:address] }
  end

  def self.GetAddressFromUprn(uprn)

		url = address_endpoint(uprn, "UPRN")

    address = JSON.parse HTTParty.get(url).response.body

    result = Hash.new

    if address.length == 0
      result = nil
    else
      result = build_address(address["results"].first)
    end

    return result
  end

  def self.GetLatLngFromPostcode(postcode)

    result = Hash.new

    begin
      postcode = Pat.get(postcode)
      result[:lat] = postcode["geo"]["lat"]
      result[:lng] = postcode["geo"]["lng"]
    rescue
      result[:lat] = 0
      result[:lng] = 0
    end

    return result
  end
end
