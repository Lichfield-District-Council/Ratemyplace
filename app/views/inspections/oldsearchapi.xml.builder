xml.instruct!
xml.ratemyplace do
	xml.results do
		@inspections.each do |inspection|
			xml.premises do 
				xml.name inspection.name
				xml.id inspection.id
				xml.link url_for :only_path => false, :controller => 'inspections', :action => 'show', :id => inspection.slug
				xml.address full_address(inspection)
				xml.town inspection.town
				xml.coords "#{inspection.lat},#{inspection.lng}"
				xml.rating inspection.rating
				xml.ratingimage "http://www.ratemyplace.org.uk/assets/rating#{inspection.rating}.png"
				xml.authority Council.find(inspection.councilid).name
			end
		end
	end
end