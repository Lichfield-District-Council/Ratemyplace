class InspectionsController < ApplicationController

before_filter :login_required, :except => [:index, :show, :search, :searchapi, :atoz, :fsa, :certificate]

  # GET /inspections
  # GET /inspections.json
  def index
    @inspections = Inspection.where(:published => 1).order("date DESC").limit(3)
    @rssinspections = Inspection.where(:published => 1).order("date DESC").limit(10)
    @search = Inspection.search(params[:search])
    @feed = Feedzirra::Feed.fetch_and_parse("http://www.food.gov.uk/news/?view=rss")

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
	      format.png { render Inspection.qrcode(request.url.gsub(/.png/, '')) }
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
	  	@search = Inspection.search(params[:q])
	  	if params[:nearest] == "1" 
	  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10).within(5, :origin => [params[:lat], params[:lng]]).order("distance ASC")
	  	else
	  		@inspections = @search.result.paginate(:page => params[:page], :per_page => 10)
	  	end
	else 
	  	@search = Inspection.search(params[:search])
	  	@inspections = Inspection.where(:published => 1).order("date DESC").limit(3)
	end
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
  
  def atoz
  	if params[:council]
  		@council = Council.find(params[:council])
  		@inspections = Inspection.where("councilid = ? AND name LIKE ? AND published = 1", @council.id, "#{params[:letter]}%")
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
  
  # GET /admin
  
  def admin
  	@user = current_user
  end
  
  def editsearch 
	if params[:q]
	  	@search = Inspection.search(params[:q])
	  	@inspections = @search.result.paginate(:page => params[:page], :per_page => 10)
	else 
	  	@search = Inspection.search(params[:search])
	end
  end
  
  def certificatesearch 
	if params[:q]
	  	@search = Inspection.search(params[:q])
	  	@inspections = @search.result.paginate(:page => params[:page], :per_page => 10)
	else 
	  	@search = Inspection.search(params[:search])
	end
	render "editsearch"
  end
  
  def certificate
  	@inspection = Inspection.find(params[:id])
  	@council = Council.find(@inspection.councilid)
  	system("curl http://lichfield-001.vm.brightbox.net/inspections/#{@inspection.slug}.png -o /tmp/#{@inspection.slug}.png")
  	@qrcode = "/tmp/#{@inspection.slug}.png"	
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
  end

  # POST /inspections
  # POST /inspections.json
  def create  	
	@inspection = Inspection.new(params[:inspection])
	
	if @inspection.rating
		if @inspection.rating < 5
			@inspection.published = 0
		else
			@inspection.published = 1
		end
	end

	if @inspection.save
	
		@inspection.buildtags
	
		if @inspection.rating == 5
			@inspection.tweet('true')
		end
		
		redirect_to @inspection, notice: 'Inspection was successfully created.'
	else
		render action: "new"
	end
  end

  # PUT /inspections/1
  # PUT /inspections/1.json
  def update
	@inspection = Inspection.find(params[:id])
	
      if @inspection.update_attributes(params[:inspection])
      	      
	    # Destroy old tags (to make sure all tags we're adding are fresh!)
    	Tag.destroy_all(:inspection_id => @inspection.id)
    	@inspection.buildtags
      	
      	newdate = Date::civil(params[:inspection]["date(1i)"].to_i, params[:inspection]["date(2i)"].to_i, params[:inspection]["date(3i)"].to_i)
      	
      	if newdate.to_s != params[:olddate].to_s
      		if @inspection.rating < 5
      			@inspection.published = 0
      			@inspection.save
      		else
      			@inspection.published = 1
      			@inspection.save
      			@inspection.tweet('true')
      		end
      	end
      	
        redirect_to @inspection, notice: 'Inspection was successfully updated.'
      else
        render action: "edit"
      end
  end
  
  # GET /inspections/1/rejectappeal
  def rejectappeal
  	@inspection = Inspection.find(params[:id])
  	@inspection.appeal = 0
  	@inspection.appealdate = 0
  	@inspection.published = 1
  	@inspection.save
  	@inspection.tweet('true')
  	redirect_to @inspection, notice: 'The appeal was rejected and the inspection is now live.'
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
