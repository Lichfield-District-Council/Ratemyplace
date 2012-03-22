class Contact
	include ActiveAttr::Model
	
	attribute :name
	attribute :email
	attribute :message
	attribute :business
	attribute :address
	attribute :council
	
	validates_presence_of :name, :message
	validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
end
