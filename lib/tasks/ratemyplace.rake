require 'uri'

namespace :upload do
	
	desc "Upload reports"
	task :reports => :environment do
		inspections = Inspection.where("report_file_name" => nil)
		issues = []
		inspections.each do |inspection|
			if inspection.reportold.length > 0
				report = URI.escape(inspection.reportold, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
				system "wget -P /tmp/ http://www.ratemyplace.org.uk/uploads/#{report}"
				inspection.update_attributes(:report => File.open("/tmp/#{inspection.reportold}")) rescue issues << "#{inspection.name} 404'd"
				inspection.save
			else
				issues << "#{inspection.name} has no report"
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
	@councils = Council.all
	@councils.each do |council|
		@inspections = Inspection.where(:councilid => council.id)
		@inspections.each do |inspection|
			system "wget -P /tmp/Certificates/#{council.slug} http://localhost:3000/admin/certificate/#{inspection.slug}.pdf"
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

desc "Get UPRNS"
task :uprn => :environment do
	inspections = Inspection.where(:uprn => nil)
	inspections.each do |inspection|
		options = []
		["name", "address1", "postcode"].each do |i|
			address = Address.GetAddressFromPostcode(inspection[i])
			
			if address.length == 1 && address[0][:postcode] == inspection.postcode
				inspection.update_attributes(:uprn => address[0][:uprn])
				inspection.save
				print "\r\n#{inspection.name} #{inspection.address} updated automagically!\r\n"
				break
			end
			
			if address.length > 0
				options << address
				break
			end
		end
		
		if options.length > 0
			num = 1
			
			print "\r\n#{inspection.name} #{inspection.address}\r\n"
			print "-----------------------------------------------------------\r\n\r\n"
			
			options[0].each do |option|
				print "#{num}: #{option[:address]}\r\n"
				num += 1
			end
			
			print "\r\nPlease enter the number of the correct address, the UPRN or x if address not present\r\n"
			print "-------------------------------------------------------------------------------------------\r\n"
			answer = STDIN.gets
			if /^[\d]+(\.[\d]+){0,1}$/ === answer
				if answer.length > 3
					uprn = answer		
				else
					choice = answer.to_i - 1
					uprn = options[0][choice][:uprn]
				end
				inspection.update_attributes(:uprn => uprn)
				inspection.save
			end
		end
	end
end

desc "Update locations based on UPRN"
task :locate => :environment do
	inspections = Inspection.where('length(uprn) > 0')
	inspections.each do |inspection|
		address = Address.GetAddressFromUprn(inspection.uprn)
		inspection.update_attributes(:lat => address[:lat], :lng => address[:lng]) rescue puts "UPRN not found for #{inspection.name}"
	end
end

namespace :foursquare do
	desc "Get Foursquare venues"
	task :venues => :environment do
		inspections = Inspection.where(:foursquare_id => nil)
		inspections.each do |inspection|
			inspection.getfoursquareid
		end
	end
	
	task :tips => :environment do
		inspections = Inspection.where("foursquare_id IS NOT NULL")
		inspections.each do |inspection|
			inspection.addfoursquaretip
		end
	end
end

desc "Make inspections live"
task :makelive => :environment do
	@inspections = Inspection.where('DATEDIFF(NOW(), date) = 27 AND published = 0 AND appeal = 0')
	@inspections.each do |inspection|
		inspection.update_attributes(:published => 1)
		inspection.tweet
		inspection.addfoursquaretip
	end
	puts "#{@inspections.count} inspections made live!"
end


desc "Upload FSA returns"
task :fsaupload => :environment do
	councils = Council.all
	councils.each do |council|
		system "wget -r -nv -P /tmp/ http://lichfield-001.vm.brightbox.net/inspections/fsa/#{council.slug}.xml && casperjs lib/fsaupload.js #{council.slug} 289 Lichsystad LichTe#T!"
	end
end

