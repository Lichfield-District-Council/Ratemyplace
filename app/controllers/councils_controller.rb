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
   		@inspections = Inspection.where(:published => 1).order("date DESC").limit(3)
	    @search = Inspection.search(params[:search])
	    @council = Council.new
	    @council.name = "All"
  	else
    	@council = Council.find(params[:id])
   		@inspections = Inspection.where(:councilid => @council.id, :published => 1).order("date DESC").limit(3)
	    @search = Inspection.search(params[:search])
	end

    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end
end
