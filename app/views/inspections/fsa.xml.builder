xml.instruct!
xml.inspections do
	@inspections.each do |inspection|
		xml.inspection do
			xml.establishmentid inspection.id
			xml.establishmentname inspection.name
			xml.establishmentaddressline1 inspection.address1
			xml.establishmentaddressline2 inspection.address2
			xml.establishmentaddressline3 inspection.address3
			xml.establishmentaddressline4 inspection.town
			xml.postcode inspection.postcode
			xml.inspectiondate inspection.date.strftime("%d/%m/%Y")
			xml.confidenceinmanagementscore inspection.confidence
			xml.hygieneandsafetyscore inspection.hygiene
			xml.structuralscore inspection.structure
			xml.businesstype "Pub/Club"
			xml.status "Included"
		end
	end
end