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
	
	def self.GetAddressFromPostcode(postcode)
	
		postcode = CGI::escape(postcode)
	
		addresses = JSON.parse HTTParty.get("https://www.lichfielddc.gov.uk/site/custom_scripts/countyllpg.php?q=#{postcode}").response.body
		
		num = 0
		results = []
				
		addresses.each do |item|
			results[num] = Hash.new
			results[num][:uprn] = item["uprn"].to_i
			results[num][:address] = item["fulladdress"]
			results[num][:address1] = item["line1"]
			results[num][:address2] = item["line2"]
			results[num][:address3] = item["line3"]
			results[num][:address4] = item["line4"]
			results[num][:town] = item["town"]
			results[num][:postcode] = item["postcode"]
			results[num][:easting] = item["easting"].to_i
			results[num][:northing] = item["northing"].to_i
			
			easting = item["easting"].to_i
			northing = item["northing"].to_i
						
			latlng = EastingNorthing.eastingNorthingToLatLong(easting, northing)
						
			results[num][:lat] = latlng["lat"]
			results[num][:lng] = latlng["long"]
			
			num += 1
		end
		
		return results
	end
	
	def self.GetAddressFromUprn(uprn)
			
		address = JSON.parse HTTParty.get("https://www.lichfielddc.gov.uk/site/custom_scripts/countyllpg.php?type=uprn&q=#{uprn}").response.body
		
		result = Hash.new
		
		if address.length == 0
			result = nil
		else		
			result[:uprn] = address[0]["uprn"].to_i
			result[:address] = address[0]["fulladdress"]
			result[:address1] = address[0]["line1"]
			result[:address2] = address[0]["line2"]
			result[:address3] = address[0]["line3"]
			result[:address4] = address[0]["line4"]
			result[:town] = address[0]["town"]
			result[:postcode] = address[0]["postcode"]
			result[:easting] = address[0]["easting"].to_i
			result[:northing] = address[0]["northing"].to_i
			
			easting = address[0]["easting"].to_i
			northing = address[0]["northing"].to_i
			
			latlng = EastingNorthing.eastingNorthingToLatLong(easting, northing)
							
			result[:lat] = latlng["lat"]
			result[:lng] = latlng["long"]
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
