xml.instruct!
xml.ratemyplace do
xml.view do
xml.premises do
xml.detail do
	xml.name @inspection.name
	xml.id @inspection.id
	xml.address full_address(@inspection)
	xml.postcode @inspection.postcode
	xml.coords "#{@inspection.lng},#{@inspection.lat}"
	xml.opening_times @inspection.hours
	xml.tel @inspection.tel
	xml.email @inspection.email
	xml.website @inspection.website
	xml.authority @council.name
	xml.reference "#{@council.code}-#{@inspection.id}"
end
xml.inspection do
	xml.date @inspection.date.strftime("%d/%m/%Y")
	xml.hygiene @inspection.hygiene
	xml.structure @inspection.structure
	xml.confidence @inspection.confidence
	xml.rating @inspection.rating
	xml.ratingimage "http://www.ratemyplace.org.uk/assets/rating#{@inspection.rating}.png" 
	xml.report "http://www.ratemyplace.org.uk#{@inspection.report.url}"
end
xml.other do
	xml.trading_standards @inspection.tradingstandards
	xml.healthy_options @inspection.healthy
end
end
end
end