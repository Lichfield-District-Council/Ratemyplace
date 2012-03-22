module InspectionsHelper

	def full_address(inspection)
		 address = [inspection.address1, inspection.address2, inspection.address3, inspection.address4, inspection.town, inspection.postcode].compact.reject { |s| s.empty? }
    	return address.join(", ")
	end
	
	def qr(inspection)
		HTTParty.post('https://www.googleapis.com/urlshortener/v1/url', :body => {'longUrl' => 'http://www.google.com'}.to_json, :options => { :headers => { 'ContentType' => 'application/json' }})
	end
	
  	def showrating(rating, type)
  		 if type == "hygiene"  		 	
  		 	case rating
	  		 	when 0 
	  		 		exp = "High standard of compliance with statutory obligations and industry codes of recommended practice; conforms to accepted good practices in the trade."
	  		 	when 5 
	  		 		exp = "High standard of compliance with statutory obligations and industry codes of recommended practice, minor contraventions of food hygiene regulations. Some minor non-compliance with statutory obligations and industry codes of recommended practice."
	  		 	when 10 
	  		 		exp = "Some non-compliance with statutory obligations and industry codes of recommended practice. The premises are in the top 50 per cent of premises and standards are being maintained or improved."
	  		 	when 15 
	  		 		exp = "Some major non-compliance with statutory obligations - more effort required to prevent fall in standards."
	  		 	when 20 
	  		 		exp = "General failure to satisfy statutory obligations - standards generally low."
	  		 	when 25 
	  		 		exp = "Almost total non-compliance with statutory obligations."
	  		 end
  		 	
  		 elsif type == "structure"  		 	
  		 	case rating
  		 		when 0
  		 			exp = "High standard of compliance with statutory obligations and industry codes of recommended practice; conforms to accepted good practices in the trade."
  		 		when 5
  		 			exp = "High standard of compliance with statutory obligations and industry codes of recommended practice, minor contraventions of food hygiene regulations. Some minor non-compliance with statutory obligations and industry codes of recommended practice."
  		 		when 10
  		 			exp = "Some non-compliance with statutory obligations and industry codes of recommended practice. The premises are in the top 50 per cent of premises and standards are being maintained or improved."
  		 		when 15
  		 			exp = "Some major non-compliance with statutory obligations - more effort required to prevent fall in standards."
  		 		when 20
  		 			exp = "General failure to satisfy statutory obligations - standards generally low."
  		 		when 25
  		 			exp = "Almost total non-compliance with statutory obligations"
  		 	end	
  		 			
  		 elsif type == "confidence"  		 	
  		 	case rating
	  		 	when 0 
	  		 		exp = "Good record of compliance. Access to technical advice within organisation. Will have satisfactory documented HACCP based food safety management system which may be subject to external audit process. Audit by Food Authority confirms compliance with documented management system with few/minor non-conformities not identified in the system as critical control points."
	  		 	when 5 
	  		 		exp = "Reasonable record of compliance. Technical advice available in-house or access to and use of technical advice from trade associations. Have satisfactory documented procedures and systems. Able to demonstrate effective control of hazards. Will have satisfactory documented food safety management system. Audit by Food Authority confirms general compliance with documented system"
	  		 	when 10 
	  		 		exp = "Satisfactory record of compliance. Access to and use of technical advice either in-house or from trade associations. May have satisfactory documented food safety management system."
	  		 	when 20 
	  		 		exp = "Varying record of compliance. Poor appreciation of hazards and control measures. No food safety management system."
	  		 	when 30 
	  		 		exp = "Poor track record of compliance. Little or no technical knowledge. Little or no appreciation of hazards or quality control. No food safety management system."
	  		 end
  		 end
  		 
  		 return (rating.to_s + ' hazard points ' + image_tag("questionmark.png", :alt => "", "data-content" => exp, :rel => "popover")).html_safe
  	end


end
