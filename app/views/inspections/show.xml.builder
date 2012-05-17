xml.instruct!
xml.inspection do
	xml.detail do
		xml.id @inspection.id
		xml.name @inspection.name
		xml.url "/inspections/#{@inspection.slug}"
		xml.address full_address(@inspection)
		unless @inspection.scope = "Included and private"
			xml.postcode @inspection.postcode
			xml.lat @inspection.lat
			xml.lng @inspection.lng
		end
		xml.opening_times @inspection.hours
		xml.email @inspection.email
		xml.website @inspection.website
	end
	xml.authority do
		xml.name @council.name
		xml.snac @council.snac
	end
	xml.inspection do
		xml.inspection_date @inspection.date
		xml.hygiene @inspection.hygiene
		xml.structure @inspection.structure
		xml.confidence @inspection.confidence
		xml.rating @inspection.rating
		xml.report @inspection.report.url
	end
	xml.other do
		xml.trading_standards @inspection.tradingstandards
		xml.healthy_options @inspection.healthy
	end
end