class CouncilsController < ApplicationController
  # GET /councils
  # GET /councils.json
  def index
    redirect_to :action => "show", :id => params[:id]
  end

  # GET /councils/1
  # GET /councils/1.json
  def show
  	if params[:id] == "all"
  		if params[:format] == "rss"
	   		@inspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND published = 1").order("date DESC").limit(10)
		    @search = Inspection.search(params[:search])
  		else
	   		@inspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND published = 1").order("date DESC").limit(3)
		    @search = Inspection.search(params[:search])
		end
	    @council = Council.new
	    @council.name = "All"
  	else
  		@council = Council.find(params[:id])
  		if params[:format] == "rss"
	   		@inspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND councilid = #{@council.id} AND published = 1").order("date DESC").limit(10)
		    @search = Inspection.search(params[:search])
  		else
	   		@inspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND councilid = #{@council.id} AND published = 1").order("date DESC").limit(3)
		    @search = Inspection.search(params[:search])
	    end
	end

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.rss do
      	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      end
    end
  end

  def redirect
  	if params[:council]
  		@council = Council.find(params[:council])
  		url = council_url(@council, :format => 'rss')
  	else
  		url = "/councils/all.rss"
  	end

  	respond_to do |format|
  		format.rss { redirect_to url, :status=>:moved_permanently }
  	end
  end

  def download
  	if params[:id] == "all"
  		@inspections = Inspection.where(:published => 1).order("date DESC")
  	else
  		@council = Council.find(params[:id])
  		@inspections = Inspection.where(:councilid => @council.id, :published => 1).order("date DESC")
  	end

  	if params[:format] == "xml"
  		stream = render_to_string(:template=>"inspections/download.builder" )
  		send_data(stream, :type => "text/xml", :filename => "#{params[:id]}.xml",:dispostion=>'inline',:status=>'200 OK')
  	elsif params[:format] == "json"
  		stream = render_to_string(:template=>"inspections/download.json_builder" )
  		send_data(stream, :type => "application/json", :filename => "#{params[:id]}.json",:dispostion=>'inline',:status=>'200 OK')
  	elsif params[:format] == "csv"
  		csv_string = CSV.generate do |csv|
			csv << ["id", "Name", "Url", "Address", "Postcode", "Latitude", "Longitude", "Opening Times", "Email", "Website", "Category", "Council Name", "Council Snac ID", "Inspection Date", "Hygiene", "Structure", "Confidence", "Rating", "Report File Name"]
			@inspections.each do |inspection|
				if inspection.private?
					inspection.postcode = "Private"
					inspection.lat = "Private"
					inspection.lng = "Private"
				end
				if inspection.hygiene == 99
					inspection.hygiene = nil
					inspection.structure = nil
					inspection.confidence = nil
				end
				if inspection.report_file_name == nil
					inspection.report_file_name = "N/A"
				else
					inspection.report_file_name = "http://www.ratemyplace.org.uk/inspections/#{inspection.report_file_name}"
				end
				council = Council.find(inspection.councilid)
				csv << [inspection.id,
						  inspection.name,
						  "http://www.ratemyplace.org.uk/inspections/#{inspection.slug}",
						  inspection.address,
						  inspection.postcode,
						  inspection.lat,
						  inspection.lng,
						  inspection.hours,
						  inspection.email,
						  inspection.website,
						  inspection.category,
						  council.name,
						  council.snac,
						  inspection.date,
						  inspection.hygiene,
						  inspection.structure,
						  inspection.confidence,
						  inspection.rating,
						  inspection.report_file_name]
			end
	end
	send_data csv_string,
		:type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=inspections.csv"
  	end
  end
end
