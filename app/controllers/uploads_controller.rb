class UploadsController < ApplicationController
  def new
    @upload = Upload.new
  end

  def create
    @workbook = Spreadsheet.open(params[:upload][:upload_file].tempfile)
    
    @worksheet = @workbook.worksheet(0)
    @inspections = []
    
    2.upto @worksheet.last_row_index do |index|
        	
    	row = @worksheet.row(index)
    	
    	unless row[21].nil?
    	
    		inspection = Hash.new
    	
	    	inspection[:internalid] = row[1]
	    	inspection[:uprn] = row[0].to_i
	    	inspection[:name] = row[3].mb_chars.downcase.to_s.titleize
	    	    	
	    	unless row[11].nil?
	    		inspection[:tel] = row[9].to_s + " " + row[11].to_s 
	    	end
			
			inspection[:category] = row[13].to_s.mb_chars.downcase.to_s.titleize
			inspection[:hygiene] = row[21]
			inspection[:structure] = row[22]
			inspection[:confidence] = row[23]
			inspection[:rating] = Inspection.getrating(inspection[:hygiene], inspection[:structure], inspection[:confidence])
			inspection[:councilid] = 1
			inspection[:published] = 1
			    	
			begin
				date = Date.parse(row[25])
			rescue
				date = ""
			end
			
			inspection[:date] = date
	    	
	    	@inspection = Inspection.where(:internalid => inspection[:internalid])
	    	
	    	if @inspection.count == 0
	    		# Add new inspection
	    		
	    		address = Address.GetAddressFromUprn(inspection[:uprn])
	    		
	    		if address.nil?
		    		inspection[:address1] = row[5].to_s.mb_chars.downcase.to_s.titleize
		    		inspection[:address2] = row[6].to_s.mb_chars.downcase.to_s.titleize
		    		inspection[:address3] = row[4].to_s + " " + row[7].to_s.mb_chars.downcase.to_s.titleize
		    		inspection[:town] = row[2].to_s.mb_chars.downcase.to_s.titleize
		    		inspection[:postcode] = row[8]
		    		latlng = Address.GetLatLngFromPostcode(inspection[:postcode])
		 	    	inspection[:lat] = latlng[:lat]
			    	inspection[:lng] = latlng[:lng]
	    		else
			    	inspection[:address1] = address[:address1]
			    	inspection[:address2] = address[:address2]
			    	inspection[:address3] = address[:address3]
			    	inspection[:address4] = address[:address4]
			    	inspection[:town] = address[:town]
			    	inspection[:postcode] = address[:postcode]
			    	inspection[:lat] = address[:lat]
			    	inspection[:lng] = address[:lng]
	    		end
	    		
	    		@inspection = Inspection.new(inspection)
	    		if @inspection.save
	    			# Save the inspection to display for further editing
	    			@inspections << @inspection
	    		else
	    			# This is where errors will go
	    			@error = @inspection
	    			break
	    		end
	    		
	    	else
	    		# Check date is the same
	    		if inspection[:date] != @inspection[0].date
	    			# If not, then update
	    			
	    			if @inspection[0].update_attributes(inspection)
	    				# Save the inspection to display for further editing
	    				@inspections << @inspection[0]
	    			else
	    				# This is where errors will go
	    				@error = @inspection
	    				break
	    			end
	    		end
	    	end
	    end
	    
	    logger.info @inspections
    end
    
  end
end
