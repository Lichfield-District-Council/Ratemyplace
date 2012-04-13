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

desc "Make inspections live"
task :makelive => :environment do
	@inspections = Inspection.where('DATEDIFF(NOW(), date) = 27 AND published = 0 AND appeal = 0')
	@inspections.each do |inspection|
		inspection.update_attributes(:published => 1)
		inspection.tweet
	end
	puts "#{@inspections.count} inspections made live!"
end