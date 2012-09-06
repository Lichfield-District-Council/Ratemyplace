class UsersController < ApplicationController
  before_filter :login_required
  
  def new 
    if session[:user_id]
    	if current_user.role >= 2
	    	@user = User.new
	    else
	    	redirect_to '/admin', :notice => "I'm afraid I can't let you do that, Dave" 
	    end
	else
		redirect_to :login
	end
  end

  def create
  	if current_user.role >= 2
  		@user = User.new
  		@user.accessible = [:role] if current_user.role >= 2
  		@user.attributes = params[:user]
  		if current_user.role == 2
    		@user.role = 1
    	end
	    if @user.save
	      redirect_to '/admin', :notice => "User created!"
	    else
	      render :action => 'new'
	    end
	 end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.accessible = [:role] if @user.role == 3
    if @user.update_attributes(params[:user])
      redirect_to '/admin', :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end
end
