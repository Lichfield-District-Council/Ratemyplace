class CouncilsController < ApplicationController
  # GET /councils
  # GET /councils.json
  def index    
    redirect_to :action => "show", :id => params[:id]
  end

  # GET /councils/1
  # GET /councils/1.json
  def show
    @council = Council.find(params[:id])
    @inspections = Inspection.where(:councilid => @council.id, :published => 1).order("date DESC").limit(3)
    @search = Inspection.search(params[:search])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @council }
    end
  end
end
