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
			unless inspection.postcode == "Mobile"
				xml.postcode inspection.postcode
			end
			xml.inspectiondate inspection.date.strftime("%d/%m/%Y")
			xml.confidenceinmanagementscore inspection.confidence
			xml.hygieneandsafetyscore inspection.hygiene
			xml.structuralscore inspection.structure
			xml.businesstype inspection.category
			xml.status inspection.scope
		end
	end
end