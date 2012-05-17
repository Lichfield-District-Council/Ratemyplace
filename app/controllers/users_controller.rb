class UsersController < ApplicationController
  before_filter :login_required
  
  def new 
    if session[:user_id]	
    	@user = User.new
	else
		redirect_to :login
	end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to '/admin', :notice => "User created!"
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to '/admin', :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end
end
