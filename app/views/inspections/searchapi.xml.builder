xml.instruct!
xml.results do
	xml.total @inspections.count
	xml.current_page @inspections.current_page
	xml.per_page @inspections.per_page
	xml.inspections do
		@inspections.each do |inspection|
			xml.inspection do
				xml.name inspection.name
				xml.uri url_for :only_path => false, :controller => 'inspections', :action => 'show', :id => inspection.slug
				xml.address full_address(inspection)
				xml.name Council.find(inspection.councilid).name
				xml.rating inspection.rating
			end
		end
	end
end