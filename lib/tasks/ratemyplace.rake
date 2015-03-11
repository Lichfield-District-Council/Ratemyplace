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
	@inspections = Inspection.where('DATEDIFF(NOW(), date) >= 27 AND published = 0 AND (appeal = 0 OR appeal IS NULL) AND scope != "Sensitive"')
	count = @inspections.count
	@inspections.each do |inspection|
		puts "Publishing..."
		inspection.update_attributes(:published => 1)
		puts "Buffering..."

		inspection.buffer
		puts "Foursquareing..."

		inspection.addfoursquaretip
	end
	puts "#{count} inspections made live!"
end

desc "Test task"
task :testtask, [:council] => :environment do |t, args|
	if args[:council].nil?
		puts "No council specified"
	else
		puts args[:council]
	end
end

desc "Upload FSA returns"
task :fsaupload, [:council] => :environment do |t, args|
	if args[:council].nil?
		councils = Council.where(:external => false)
	else
		councils = Council.where(:logo => args[:council])
	end
	councils.each do |council|
		puts "Uploading #{council.name}..."
		system "wget -N -nv -P /tmp/ http://www.ratemyplace.org.uk/inspections/fsa/#{council.slug}.xml > /dev/null 2>&1 && PHANTOMJS_EXECUTABLE=\"/usr/local/bin/phantomjs\" /usr/local/bin/casperjs #{Rails.root}/lib/fsaupload.js #{FSA_CONFIG[:url]} #{council.slug} #{"%03d" % council.fsaid} #{council.username} #{council.password}"
	end
end

desc "Generate reports for users"
task :reports => :environment do
	users = User.all
	users.each do |user|

		reports = {}

		#No Reports
		reports['noreports'] = Inspection.where(:report_file_name => nil, :councilid => user.councilid).count

		#Reports not in PDF format
		reports['pdf'] = Inspection.where('report_file_name not LIKE ? and councilid = ?', '%pdf%', user.councilid).count

		#No Annex 5 score
		reports['annex5'] = Inspection.where(:annex5 => nil, :councilid => user.councilid).count

		#Possible duplicates
		reports['duplicates'] = Inspection.find_by_sql("SELECT inspections.name, inspections.councilid, inspections.address1, inspections.address2, inspections.address3, inspections.address4, inspections.town, inspections.postcode, inspections.tel, inspections.email, inspections.website, inspections.operator, inspections.category, inspections.scope, inspections.hygiene, inspections.structure, inspections.confidence, inspections.rating, inspections.annex5, inspections.date, inspections.slug FROM inspections INNER JOIN (SELECT inspections.id, inspections.name, inspections.postcode, count(*) FROM inspections WHERE councilid = #{user.councilid} GROUP BY inspections.name, inspections.postcode HAVING count(*) > 1) dup ON inspections.name = dup.name WHERE councilid = #{user.councilid} ORDER by inspections.name ASC").count

		total = reports.values.inject(:+)

		if total > 0
			ReportMailer.report(user, reports).deliver
		end

	end
end

desc "Import external inspections"
task :import => :environment do
	Import.all
end
