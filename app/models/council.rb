class Council < ActiveRecord::Base
	has_many :inspections
	has_many :users
	 
	extend FriendlyId
  	friendly_id :name, use: :slugged
end
