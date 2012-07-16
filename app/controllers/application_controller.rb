class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  
  unless config.consider_all_requests_local
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end 
  
  private

  def render_not_found(exception)
    Rails.logger.error(exception)
    render :template => "/static/404.html.haml", :status => 404
  end

  def render_error(exception)
    Rails.logger.error(exception)
    render :template => "/static/500.html.haml", :status => 500
  end
  
end
