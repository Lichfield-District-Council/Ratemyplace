class Inspection < ActiveRecord::Base
	require 'httparty'
	require 'json'
	
	belongs_to :council
	has_many :tags
	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
	has_attached_file :report
	has_attached_file :menu
	acts_as_mappable
	
	validates_presence_of :name, :address1, :town, :postcode, :hygiene, :structure, :confidence, :rating, :date, :councilid
	
	validates :date,
			  :date => {:before => Proc.new { Time.now + 1.day }, :message => 'must be in the past'}
			
  	extend FriendlyId
  	friendly_id :name_and_town, use: :slugged
  	
  	def name_and_town
  		"#{name} #{town}"
  	end
  	
  	require 'urlshortener'
  	require 'buffer_app'
  	
  	def self.qrcode(url)
	  	return :qrcode => UrlShortener.shorten(url).short_url, :offset => 5
  	end
  	
  	def buildtags
  		if tags.length > 0
		    taglist = params[:tags].split(",")
		   	taglist.each { |tag|
		    	self.tags.build({"tag" => tag.strip})
		    }
	    end
  	end
  	
  	def address(seperator = ", ")
  		address = [self.address1, self.address2, self.address3, self.address4, self.town, self.postcode].compact.reject { |s| s.empty? }
    	return address.join(seperator)
  	end
  	
  	def getfoursquareid
  		result = JSON.parse HTTParty.get("https://api.foursquare.com/v2/venues/search?ll=#{self.lat},#{self.lng}&query=#{CGI::escape(self.name)}&radius=50&oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}").response.body
  		if result["response"]["venues"].length == 0
  			foursquare_id = nil
  		else
  			foursquare_id = result["response"]["venues"][0]["id"].split.join("\n")
  		end
  		self.update_attributes(:foursquare_id => foursquare_id)
  		self.save
  		
  		rescue Exception => e
  			puts "#{self.name} raised error"
  	end
  	
  	def addfoursquaretip
  		if self.foursquare_id == nil
  			self.foursquare_id = self.getfoursquareid
  		end
  		
  		text = "Food safety rating here is #{self.rating} out of 5"
  		url = "http://www.ratemyplace.org.uk/inspections/#{self.slug}"
  		
  		options = {:query => { :venueId => self.foursquare_id, :text => text, :url => url }}
  		HTTParty.post("https://api.foursquare.com/v2/tips/add?oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}", options )
  		
  		rescue Exception => e
  			puts "#{self.name} raised error #{e}"
  	end
  	
  	def getrating
  		stars = self.hygiene + self.structure + self.confidence
		
		if stars >=0 and stars <=15
			if hygiene > 5 or structure > 5 or confidence > 5
				rating = 4
			elsif hygiene > 10 or structure > 10 or confidence > 10
				rating = 2
			elsif hygiene > 15 or structure > 15 or confidence > 15
				rating = 1
			elsif hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			else
				rating = 5
			end
		elsif stars >=16 and stars <=20
			if hygiene > 10 or structure > 10 or confidence > 10 
				rating = 2
			elsif hygiene > 15 or structure > 15 or confidence > 15 
				rating = 1
			elsif hygiene > 20 or structure > 20 or confidence > 20 
				rating = 0
			else
				rating = 4
			end
		elsif stars >=21 and stars <=30 
			if hygiene > 10 or structure > 10 or confidence > 10 
				rating = 2
			elsif hygiene > 15 or structure > 15 or confidence > 15 
				rating = 1
			elsif hygiene > 20 or structure > 20 or confidence > 20 
				rating = 0
			else
				rating = 3
			end
		elsif  stars >=31 and stars <=40
			if hygiene > 15 or structure > 15 or confidence > 15 
				rating = 1
			elsif hygiene > 20 or structure > 20 or confidence > 20 
				rating = 0
			else
				rating = 2
			end
		elsif  stars >=41 and stars <=50 
			if hygiene > 20 or structure > 20 or confidence > 20 
				rating = 0
			else
				rating = 1
			end
		elsif  stars >= 50
			rating = 0
		end
		
		self.update_attributes(:rating => rating)
  		self.save
		
		return rating
  	end
  	
  	def tweet(now = false)
  		BufferApp.new(BUFFER_CONFIG[:token], BUFFER_CONFIG[:id]).create("New Inspection: #{self.name} #{self.town} #{self.rating} stars #{"http://www.ratemyplace.org.uk/inspections/" + self.slug}", now)
  	end
  	
  	def reportsize
  		size = self.report.size / 1000
  		return size.to_s + "kb"
  	end
  	
end
