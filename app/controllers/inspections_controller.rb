class InspectionsController < ApplicationController
require "csv"

before_filter :login_required, :except => [:index, :show, :search, :searchapi, :atoz, :fsa, :certificate, :locate, :nearest, :api, :layar, :qr, :redirect, :tags]

  # GET /inspections
  # GET /inspections.json
  def index
    @inspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND published = 1").order("date DESC").limit(3)
    if params[:layar]
	    @rssinspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND published = 1").order("date DESC")
	else
		@rssinspections = Inspection.where("DATEDIFF(NOW(), date) >= 27 AND published = 1").order("date DESC").limit(10)
	end
    @search = Inspection.search(params[:search])
    feed = Feedzirra::Feed.fetch_and_parse("http://www.food.gov.uk/news/?view=rss", :timeout => 10)
    @entries = feed.entries rescue nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inspections }
      format.rss do
      	response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      end
    end
  end

  # GET /inspections/1
  # GET /inspections/1.json
  def show
    @inspection = Inspection.find(params[:id])
    @council = Council.find(@inspection.councilid)
    @tags = @inspection.tags

    if @inspection.published == false && !session[:user_id]
    	redirect_to root_url
    else
	    respond_to do |format|
	      format.html # show.html.erb
	      format.json
	      format.xml
	      format.js
	      format.png do
	      	params[:type] == "cert" ? utm_campaign = "certificate" : utm_campaign = "usergenerated"
	      	render @inspection.qrcode(utm_campaign)
	      end
	    end
	end
  end

  def qr
  	@inspection = Inspection.find(params[:id])
  	respond_to do |format|
  		format.png do
        params[:type] == "cert" ? utm_campaign = "certificate" : utm_campaign = "usergenerated"
        render @inspection.qrcode(utm_campaign)
      end
  	end
  end

  def redirect
  	@inspection = Inspection.find(params[:id])

  	respond_to do |format|
  		format.html { redirect_to inspection_url(@inspection), :status=>:moved_permanently }
  		format.js { redirect_to inspection_url(@inspection, :format => 'js'), :status=>:moved_permanently }
  	end
  end

  # GET /inspections/search
  def search
	if params[:q]
		if !session[:user_id]
			params[:q][:published_eq] = 1
		end
		@title = "Search results"
	  	@search = Inspection.search(params[:q])
	  	if params[:nearest] == "1"
	  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).within(5, :origin => [params[:lat], params[:lng]]).order("distance ASC")
	  	else
	  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).order("name ASC")
	  	end
	else
	  	@search = Inspection.search(params[:search])
	  	@inspections = Inspection.where(:published => 1).order("date DESC").limit(3)
	end
  end

  def tags
  	@title = "Businesses tagged '#{params[:tag]}'"
  	@inspections = Inspection.joins(:tags).where(:tags => {:tag => params[:tag]}).paginate(:page => params[:page], :per_page => 10).order("name ASC")

  end

  def searchapi

  	if params[:q]
  		params[:q][:published_eq] = 1
  		query = params[:q]
  	else
  		query = {"name_cont" => params[:name], "category_eq" => params[:category], "councilid_eq" => params[:council], "town_cont" => params[:town], "rating_eq" => params[:rating], "published_eq" => 1}
  	end

  	@search = Inspection.search(query)
  	if params[:distance]
  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).within(params[:distance], :origin => [params[:lat], params[:lng]]).order("distance ASC")
  	else
  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10)
  	end
  end

  def api
  	if params[:method] == "search"

  		if params[:top] == "true"
  			@inspections = Inspection.where(:published => 1).order("date DESC").limit(10)
  		else
	  		@search = Inspection.search({"name_cont" => params[:name], "councilid_eq" => params[:authority], "town_cont" => params[:town], "rating_eq" => params[:rating], "published_eq" => 1})
	  		if params[:lat]
	  			@inspections = @search.result.within(params[:distance], :origin => [params[:lat], params[:lng]]).order("distance ASC")
	  		else
	  			@inspections = @search.result
	  		end
		end

	  	if params[:format] == "json"
	  		render "oldsearchapi.json_builder"
	  	else
	  		render "oldsearchapi.xml.builder"
	  	end
  	end

  	if params[:method] == "view"
  		@inspection = Inspection.find(params[:id])
  		@council = Council.find(@inspection.councilid)

  		 if params[:format] == "json"
  			render "oldviewapi.json_builder"
  		else
  			render "oldviewapi.xml.builder"
  		end
  	end
  end

  def layar
  	  distance = params[:radius].to_i / 1609.344
	  @inspections = Inspection.search({"published_eq" => 1}).result.within(distance, :origin => [params[:lat], params[:lon]]).order("distance ASC")
	  render "layar.json_builder"
  end

  def atoz
  	if params[:council]
  		@council = Council.find(params[:council])
  		@inspections = Inspection.where("councilid = ? AND name LIKE ? AND published = 1", @council.id, "#{params[:letter]}%").order("name ASC")
  	else
  		@councils = Council.all
  	end
  end

  def fsa
  	@council = Council.find(params[:council])
  	@inspections = Inspection.where(:councilid => @council.id)
  	stream = render_to_string(:template=>"inspections/fsa.builder" )
  	send_data(stream, :type => "text/xml", :filename => "#{@council.slug}.xml",:dispostion=>'inline',:status=>'200 OK')
  end

  def locate
  	if params[:lat]
	  	inspection = Inspection.within(1, :origin => [params[:lat], params[:lng]]).order('distance asc').first
	  	respond_to do |format|
	  		format.html { redirect_to inspection_url(inspection, :utm_source => 'qrcode', :utm_medium => 'qrcode', :utm_campaign => 'window_sticker') }
	  	end
	 else
	  	respond_to do |format|
	  		format.html { render :layout=>false }
	  	end
	 end
  end

  # GET /admin

  def admin
  	@user = current_user
  	@council = Council.find(@user.councilid)
  end

  def editsearch
	if params[:q]

	  	if params[:title] == "publication"
	  		@inspections =  Inspection.search(params[:q]).result.where('DATEDIFF(NOW(), date) <= 27 AND published = 0 AND (appeal = 0 OR appeal IS NULL) AND scope != "Sensitive"').paginate(:page => params[:page], :per_page => 10).order("name ASC")
	  	elsif params[:title] == "dupes"
	  		@inspections =  Inspection.paginate_by_sql("SELECT inspections.name, inspections.councilid, inspections.address1, inspections.address2, inspections.address3, inspections.address4, inspections.town, inspections.postcode, inspections.tel, inspections.email, inspections.website, inspections.operator, inspections.category, inspections.scope, inspections.hygiene, inspections.structure, inspections.confidence, inspections.rating, inspections.annex5, inspections.date, inspections.slug FROM inspections INNER JOIN (SELECT inspections.id, inspections.name, inspections.postcode, count(*) FROM inspections WHERE councilid = #{params[:q][:councilid_eq]} GROUP BY inspections.name, inspections.postcode HAVING count(*) > 1) dup ON inspections.name = dup.name WHERE councilid = #{params[:q][:councilid_eq]} ORDER by inspections.name ASC", :page => params[:page], :per_page => 10)
	  	else
	  		@search = Inspection.search(params[:q])
	  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).order("name ASC")
	  	end


	  	respond_to do |format|
	  		format.html
	  		format.csv do
	  			if params[:title] == "publication"
	  				@inspections = Inspection.search(params[:q]).result.where('DATEDIFF(NOW(), date) <= 27 AND published = 0 AND appeal = 0 AND scope != "Sensitive"')
			  	elsif params[:title] == "dupes"
			  		@inspections =  Inspection.find_by_sql("SELECT inspections.name, inspections.councilid, inspections.address1, inspections.address2, inspections.address3, inspections.address4, inspections.town, inspections.postcode, inspections.tel, inspections.email, inspections.website, inspections.operator, inspections.category, inspections.scope, inspections.hygiene, inspections.structure, inspections.confidence, inspections.rating, inspections.annex5, inspections.date, inspections.slug FROM inspections INNER JOIN (SELECT inspections.id, inspections.name, inspections.postcode, count(*) FROM inspections WHERE councilid = #{params[:q][:councilid_eq]} GROUP BY inspections.name, inspections.postcode HAVING count(*) > 1) dup ON inspections.name = dup.name WHERE councilid = #{params[:q][:councilid_eq]} ORDER by inspections.name ASC")
			  	else
	  				@inspections = @search.result
	  			end
	  			csv_string = CSV.generate do |csv|
				csv << ["Name", "Address1", "Address2", "Address3", "Town", "Postcode", "Tel", "Email", "Website", "Operator", "Category", "Scope", "Hygiene", "Structure", "Confidence", "Rating", "Annex 5 overall rating", "Inspection Date", "Link"]
					@inspections.each do |inspection|
						csv << [inspection.name,
								  inspection.address1,
								  inspection.address2,
								  inspection.address3,
								  inspection.town,
								  inspection.postcode,
								  inspection.tel,
								  inspection.email,
								  inspection.website,
								  inspection.operator,
								  inspection.category,
								  inspection.scope,
								  inspection.hygiene,
								  inspection.structure,
								  inspection.confidence,
								  inspection.rating,
								  inspection.annex5,
								  inspection.date,
								  "http://www.ratemyplace.org.uk/inspections/#{inspection.slug}" ]
					end
				end

				send_data csv_string,
					:type => 'text/csv; charset=iso-8859-1; header=present',
			        :disposition => "attachment; filename=inspections.csv"
	  		end
	  	end
	else
		@councilid = current_user.councilid
	  	@search = Inspection.search(params[:search])
	end
  end

  # GET /reports
  def reports
  	if session[:user_id]
  		@user = current_user
  		@council = Council.find(@user.councilid)
  		@search = Inspection.search(params[:search])
  	else
 		redirect_to :login
  	end
  end

  def certificatesearch
	if params[:q]
	  	@search = Inspection.search(params[:q])
	  	@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).order("name ASC")
	else
	  	@search = Inspection.search(params[:search])
	end
	render "editsearch"
  end

  def foursquarecleanup
  	if params[:id]
  		inspection = Inspection.find(params[:id])
  		if params[:approve] == "1"
  			inspection.update_attributes(:foursquare_id => params[:foursquare_id])
  		else
  			inspection.update_attributes(:foursquare_id => "x")
  			if inspection.foursquare_tip_id != nil
  				inspection.removefoursquaretip
  			end
  		end
  	end
	@search = Inspection.search(:foursquare_id_cont => "?")
	@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).order("name ASC")
  end

  def certificate
  	@inspection = Inspection.find(params[:id])
  	@council = Council.find(@inspection.councilid)
    t = Tempfile.new(@inspection.slug)
    t << open(inspection_url(@inspection, format: "png", type: "cert", host: request.host_with_port)).read
    t.close
  	@qrcode = t.path
  	respond_to do |format|
  		format.pdf do
	  		render :pdf => @inspection.slug,
	  			   :show_as_html => params[:debug].present?,
	  			   :margin => {:top            => 0,
                           	   :bottom         => 0,
                               :left           => 0,
                               :right          => 0}
	  	end
  	end
  end

  # GET /inspections/new
  # GET /inspections/new.json
  def new
  	if session[:user_id]
	    @inspection = Inspection.new
	    @councils = Council.all
	    @addressclass = "hidden"
	    user = current_user
  		@inspection.councilid = user.councilid

	    respond_to do |format|
	      format.html # new.html.erb
	      format.json { render json: @inspection }
	    end
	else
		redirect_to :login
	end
  end

  # GET /inspections/1/edit
  def edit
	@addressclass = "visible"
	@inspection = Inspection.find(params[:id])
	@tags = @inspection.tags
	taglist = []
	@tags.each { |tag|
		taglist << tag.tag
	}
	@tags = taglist.join(",")
	@findclass = 'hidden'
  end

  # POST /inspections
  # POST /inspections.json
  def create

  	params[:inspection][:name] = params[:inspection][:name].titleize

  	if params[:inspection][:scope] == "Included and private"
	  	params[:inspection][:lat] = 0
	  	params[:inspection][:lng] = 0
	end

	@inspection = Inspection.new(params[:inspection])

	if @inspection.rating
		if @inspection.rating < 5
			@inspection.published = 0
		else
			@inspection.published = 1 unless @inspection.scope == "Sensitive"
		end

		if @inspection.rating == -1
			@inspection.hygiene = 99
			@inspection.structure = 99
			@inspection.confidence = 99
		end
	end

	if @inspection.save

		@inspection.buildtags(params[:tags])

		if @inspection.rating == 5
			@inspection.tweet('true') unless @inspection.scope == "Sensitive"
			@inspection.addfoursquaretip unless @inspection.scope == "Sensitive"
		end

		redirect_to @inspection, notice: 'Inspection was successfully created.'
	else
		if @inspection.address1.length == 0
			@addressclass = "hidden"
		end
		render action: "new"
	end
  end

  # PUT /inspections/1
  # PUT /inspections/1.json
  def update
	@inspection = Inspection.find(params[:id])

	  params[:inspection][:name] = params[:inspection][:name].titleize

	  if params[:inspection][:scope] == "Included and private"
	  	params[:inspection][:lat] = 0
	  	params[:inspection][:lng] = 0
	  end

      if @inspection.update_attributes(params[:inspection])

	    # Destroy old tags (to make sure all tags we're adding are fresh!)
    	Tag.destroy_all(:inspection_id => @inspection.id)
    	@inspection.buildtags(params[:tags])

      	newdate = Date::civil(params[:inspection]["date(1i)"].to_i, params[:inspection]["date(2i)"].to_i, params[:inspection]["date(3i)"].to_i)

      	if newdate.to_s != params[:olddate].to_s
      		if @inspection.rating < 5 && @inspection.rating >= 0
      			@inspection.published = 0
      			@inspection.save
      		else
      			@inspection.published = 1 unless @inspection.scope == "Sensitive"
      			@inspection.save
      			@inspection.tweet('true') unless @inspection.scope == "Sensitive"
      			@inspection.addfoursquaretip unless @inspection.scope == "Sensitive"
      		end
      	elsif (Date.today - newdate).to_i < 27 && @inspection.rating < 5
      		@inspection.published = 0
      		@inspection.save
      	else
      		@inspection.published = 1
      		@inspection.save
      	end

      	if params[:inspection][:appeal] == "1"
      		@inspection.lodgeappeal(Date::civil(params[:inspection]["appealdate(1i)"].to_i, params[:inspection]["appealdate(2i)"].to_i, params[:inspection]["appealdate(3i)"].to_i))
      	end

      	if params[:inspection][:appeal] == "0"
      		@inspection.acceptappeal
  			@inspection.published = 1 unless @inspection.scope == "Sensitive"
  			@inspection.save
  			@inspection.tweet('true') unless @inspection.scope == "Sensitive"
  			@inspection.addfoursquaretip unless @inspection.scope == "Sensitive"
      	end

        redirect_to @inspection, notice: 'Inspection was successfully updated.'
      else
      	@findclass = 'hidden'
        render action: "edit"
      end
  end

  # GET /inspections/1/rejectappeal
  def rejectappeal
  	@inspection = Inspection.find(params[:id])
  	@inspection.appeal = 0
  	@inspection.appealdate = 0
  	@inspection.published = 1 unless @inspection.scope == "Sensitive"
  	@inspection.save
  	@inspection.tweet('true') unless @inspection.scope == "Sensitive"
  	@inspection.rejectappeal
  	redirect_to @inspection, notice: 'The appeal was rejected and the inspection is now live.'
  end

  def matchaddress
    @inspection = Inspection.where("uprn = '' OR uprn IS null").limit(1)
    if @inspection[0] == nil
    	redirect_to '/', notice: "Nice! All done! :)"
    else
		@addresses = Address.where("postcode = ? OR (fulladdress LIKE ? AND town = ?)", @inspection[0].postcode, "%#{@inspection[0].address1}%", @inspection[0].town)
	end
  end

  def updateaddress
  	inspection = Inspection.find(params[:inspection][:id])
  	if params[:inspection][:uprn] == "x"
  		inspection.update_attributes(:uprn => "x")
  	elsif params[:altuprn] != nil
  		latlng = Address.where(:uprn => "#{params[:altuprn]}.00")[0].latlng
  		inspection.update_attributes(:uprn => params[:altuprn], :lat => latlng[:lat], :lng => latlng[:lng])
  	else
	  	latlng = Address.where(:uprn => "#{params[:inspection][:uprn]}.00")[0].latlng
  		inspection.update_attributes(:uprn => params[:inspection][:uprn], :lat => latlng[:lat], :lng => latlng[:lng])
  	end
  	redirect_to :matchaddress, notice: "Premises updated! Now, what's next?"
  end

  def deleteattachment
  	inspection = Inspection.find(params[:id])
  	if params[:type] == "image"
  	  inspection.image = nil
  	  @update = true
  	elsif params[:type] == "report"
  	  inspection.report = nil
  	  @update = true
  	elsif params[:type] == "menu"
  	  inspection.menu = nil
  	  @update = true
  	end
  	inspection.save
  end

  # DELETE /inspections/1
  # DELETE /inspections/1.json
  def destroy
    @inspection = Inspection.find(params[:id])
    Tag.destroy_all(:inspection_id => @inspection.id)
    @inspection.destroy

    respond_to do |format|
      format.html { redirect_to inspections_url }
      format.json { head :no_content }
    end
  end
end
