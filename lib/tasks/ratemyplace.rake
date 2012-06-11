require 'uri'
require 'easting_northing'

namespace :upload do
	
	desc "Upload reports"
	task :reports => :environment do
		inspections = Inspection.all
		issues = []
		inspections.each do |inspection|
			if inspection.reportold.length > 0
				report = URI.escape(inspection.reportold, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub("(", "\\(").gsub(")", "\\)")
				system "wget -P /tmp/ http://www.ratemyplace.org.uk/uploads/#{report}"
				inspection.update_attributes(:report => File.open("/tmp/#{inspection.reportold}")) rescue issues << "#{inspection.name} 404'd"
				inspection.save
			else
				# issues << "#{inspection.name} has no report"
			end
		end
		if issues.count > 0
			puts "There were #{issues.count} premises with problems:"
			puts "--------------------------------------------------"
			issues.each do |issue|
				puts issue
			end
		else
			puts "All reports uploaded successfully!"
		end
	end	
	
	desc "Upload images"
	task :images => :environment do
		inspections = Inspection.where("length(imageold) > 0 AND image_file_name IS NULL")
		issues = []
		inspections.each do |inspection|
			image = URI.escape(inspection.imageold, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
			system "wget -P /tmp/ http://www.ratemyplace.org.uk/uploads/#{image}"
			inspection.update_attributes(:image => File.open("/tmp/#{inspection.imageold}")) rescue issues << "#{inspection.name} 404'd"
			inspection.save
		end
		if issues.count > 0
			puts "There were #{issues.count} premises with problems:"
			puts "--------------------------------------------------"
			issues.each do |issue|
				puts issue
			end
		else
			puts "All images uploaded successfully!"
		end
	end	
	
end

desc "Generate and download all certificates"
task :certificates => :environment do
	@councils = Council.where(:id => 2)
	@councils.each do |council|
		@inspections = Inspection.where(:councilid => council.id)
		@inspections.each do |inspection|
			system "wget -P /tmp/Certificates/#{council.slug}/#{inspection.rating} http://localhost:3000/admin/certificate/#{inspection.slug}.pdf"
		end
	end
end

desc "Generate slugs"
task :slugify => :environment do
	Inspection.find_each(&:save)
end

desc "Update scores to new scheme"
task :newrating => :environment do
	inspections = Inspection.all
	inspections.each do |inspection|
		inspection.getrating
	end
end

desc "Make non live premises live"
task :live => :environment do
	@inspections = Inspection.where('DATEDIFF(NOW(), date) > 27 AND scope != "Sensitive"')
	@inspections.each do |inspection|
		inspection.update_attributes(:published => 1)
	end
end

namespace :foursquare do
	desc "Get Foursquare venues"
	task :venues => :environment do
		inspections = Inspection.where('(foursquare_id = "" OR foursquare_id is NULL) AND lat != 0')
		inspections.each do |inspection|
			inspection.getfoursquareid
		end
	end
	
	task :tips => :environment do
		inspections = Inspection.where("foursquare_id != 'x'")
		inspections.each do |inspection|
			inspection.addfoursquaretip
		end
	end
	
	task :check => :environment do
		inspections = Inspection.where("foursquare_id != 'x' AND foursquare_id != '' AND foursquare_id is not NULL AND foursquare_id not like '%?%' AND foursquare_name IS NULL")
		inspections.each do |i|
			result = JSON.parse HTTParty.get("https://api.foursquare.com/v2/venues/#{i.foursquare_id}?oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}").response.body
			if result["meta"]["code"] == 200
				i.update_attributes(:foursquare_id => "#{i.foursquare_id}?", :foursquare_name => result["response"]["venue"]["name"])
				i.save
			else
	  			puts "#{i.name} raised error #{result["meta"]["errorDetail"]}"
	  			break
	  		end
		end
	end
end

desc "Make inspections live"
task :makelive => :environment do
	@inspections = Inspection.where('DATEDIFF(NOW(), date) >= 27 AND published = 0 AND appeal = 0 AND scope != "Sensitive"')
	count = @inspections.count
	@inspections.each do |inspection|
		inspection.update_attributes(:published => 1)
		inspection.tweet
		inspection.addfoursquaretip
	end
	puts "#{count} inspections made live!"
end


desc "Upload FSA returns"
task :fsaupload => :environment do
	councils = Council.where(:external => false)
	councils.each do |council|
		puts "Uploading #{council.name}..."
		system "wget -N -nv -P /tmp/ http://lichfield-001.vm.brightbox.net/inspections/fsa/#{council.slug}.xml > /dev/null 2>&1 && PHANTOMJS_EXECUTABLE=\"/usr/local/bin/phantomjs\" /usr/local/bin/casperjs #{Rails.root}/lib/fsaupload.js #{FSA_CONFIG[:url]} #{council.slug} #{"%03d" % council.fsaid} #{council.username} #{council.password}"
	end
end

desc "Import external inspections"
task :import => :environment do
	require 'httparty'
	require 'nokogiri'
	require 'pat'
	
	councils = Council.where(:external => true)
	councils.each do |council|
	
		doc = Nokogiri::XML HTTParty.get("http://ratings.food.gov.uk/OpenDataFiles/FHRS#{council.id}en-GB.xml").response.body
		
		inspections = []
		count = 0
	
		doc.search('EstablishmentDetail').each do |i|
			inspections << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
		end
		
		inspections.each do |i|
			if i["RatingValue"] != "Exempt" 
				inspection = Inspection.find_or_create_by_internalid(i["FHRSID"])
				if i["RatingDate"].to_date != inspection.date
					if inspection.lat == nil
						begin
							postcode = Pat.get(i["PostCode"])
							lat = postcode["geo"]["lat"]
							lng = postcode["geo"]["lng"]
						rescue
							lat = 0
							lng = 0
						end
					else
						lat = inspection.lat
						lng = inspection.lng
					end
					
					address = [i["AddressLine1"], i["AddressLine2"], i["AddressLine3"], i["AddressLine4"]].compact.reject { |s| s.empty? || s == "Staffordshire" }
					
					if address.length == 4
						town = address[3]
						address[3] = nil
					elsif address.length == 3
						town = address[2]
						address[2] = nil
					elsif
						town = address[1]
						address[1] = nil
					else
						town = address[0]
					end
					
					if i["PostCode"].blank?
						i["PostCode"] = "x"
					end
					
					inspection.update_attributes(:name => i["BusinessName"].titleize, :address1 => address[0], :address2 => address[1], :address3 => address[2], :town => town, :postcode => i["PostCode"], :uprn => "x", :category => i["BusinessType"], :scope => "included", :hygiene => 99, :structure => 99, :confidence => 99, :rating => i["RatingValue"], :date => i["RatingDate"], :councilid => i["LocalAuthorityCode"], :lat => lat, :lng => lng, :published =>  1, :hours => "", :tel => "", :email => "", :website => "")
					inspection.save
					inspection.tweet
					count += 1
					
					if inspection.errors.any?
						inspection.errors.full_messages.each do |msg|
							puts msg
						end
					end
				end
			end
		end
		
		puts "#{count} inspection(s) added for #{council.name}!"
	end
end