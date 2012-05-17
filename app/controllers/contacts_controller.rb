class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    if params[:council]
    	@contact.council = params[:council]
    end
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      ContactUs.contact_email(@contact).deliver
      redirect_to root_url, notice: "Message sent! Thank you for contacting us."
    else
      render "new"
    end
  end
end
