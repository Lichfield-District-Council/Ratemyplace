class Inspection < ActiveRecord::Base
	include Rails.application.routes.url_helpers

	Rails.env == "development" ? default_url_options[:host] = "ratemyplace.dev" : default_url_options[:host] = "ratemyplace.org.uk"

	require 'httparty'
	require 'json'

	belongs_to :council
	has_many :tags
	has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
	has_attached_file :report

	has_attached_file :menu
	acts_as_mappable

	validate :sensitive_inspections_cant_be_published
	validates_presence_of :name, :address1, :town, :postcode, :hygiene, :structure, :confidence, :rating, :category, :scope, :date, :councilid

	validates :date,
			  :date => {:before => Proc.new { Time.now + 1.day }, :message => 'must be in the past'}

	validates_attachment_content_type :report, :content_type => ["application/pdf"], :message => "must be PDF format"
	validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/png", "image/gif"], :message => "must be jpeg, png or gif format"

  	extend FriendlyId
  	friendly_id :name_and_town, use: :slugged

  	def sensitive_inspections_cant_be_published
  		if scope == 'Sensitive' and published == true
  			errors[:base] << "Sensitive inspections can't be published"
  		end
  	end

  	def name_and_town
  		"#{name} #{town}"
  	end

  	require 'urlshortener'
  	require 'buffer_app'

  	def qrcode(utm_campaign)
			url = inspection_url(self, :utm_source => "qr_code", :utm_medium => "qrcode", :utm_campaign => utm_campaign)

	  	return :qrcode => UrlShortener.shorten(url).short_url, :offset => 5
  	end

  	def buildtags(tags)
  		if tags != nil
		    taglist = tags.split(",")
		   	taglist.each { |tag|
		   		if tag.length > 0
			    	self.tags.build({"tag" => tag.strip})
			    end
		    }
		    self.save
	    end
  	end

  	def address(seperator = ", ")
  		if self.private?
  			address = self.postcode.split(" ")[0]
  			return address
  		else
  			address = [self.address1, self.address2, self.address3, self.address4, self.town, self.postcode].compact.reject { |s| s.empty? }
  			return address.join(seperator)
  		end
  	end

  	def getfoursquareid(force = false)
  		result = JSON.parse HTTParty.get("https://api.foursquare.com/v2/venues/search?ll=#{self.lat},#{self.lng}&query=#{CGI::escape(self.name)}&radius=10&oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}").response.body
  		if result["meta"]["code"] == 200
	  		if result["response"]["venues"].length == 0
	  			foursquare_id = "x"
	  		else
	  			if force === false
		  			white = Text::WhiteSimilarity.new
		  			if white.similarity(result["response"]["venues"][0]["name"], self.name) > 0.5
			  			foursquare_id = result["response"]["venues"][0]["id"].split.join("\n")
			  		else
			  			foursquare_id = "?"
			  		end
		  		else
		  			foursquare_id = result["response"]["venues"][0]["id"].split.join("\n")
		  			foursquare_name = result["response"]["venues"][0]["name"].split.join("\n")
		  		end
	  		end
	  		self.update_attributes(:foursquare_id => foursquare_id, :foursquare_name => foursquare_name)
	  		self.save
	  	else
	  		puts "#{self.name} raised error #{result["meta"]["errorDetail"]}"
	  	end
  	end

  	def addfoursquaretip
  		if self.foursquare_id == nil
  			self.foursquare_id = self.getfoursquareid
  		end

  		if self.foursquare_id != "x"
	  		if self.foursquare_tip_id != nil
		  		HTTParty.post("https://api.foursquare.com/v2/tips/#{self.foursquare_tip_id}/delete?oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}") rescue puts "#{self.foursquare_id} caused an error when deleting an old tip"
			end

	  		text = "Food safety rating here is #{self.rating} out of 5"
	  		url = "http://www.ratemyplace.org.uk/inspections/#{self.slug}"

	  		options = {:query => { :venueId => self.foursquare_id, :text => text, :url => url }}
	  		post = JSON.parse HTTParty.post("https://api.foursquare.com/v2/tips/add?oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}", options ).response.body rescue puts "#{self.foursquare_id} caused an error when POSTing a new tip"
	  		if post["meta"]["code"] == 200
		  		self.update_attributes(:foursquare_tip_id => post["response"]["tip"]["id"])
		  		self.save
		  	end
  		end
  	end

  	def removefoursquaretip
  		HTTParty.post("https://api.foursquare.com/v2/tips/#{self.foursquare_tip_id}/delete?oauth_token=#{FOURSQUARE_CONFIG[:token]}&v=#{Date.today.strftime("%Y%m%d")}")
  		self.update_attributes(:foursquare_tip_id => "x")
  	end


  	def ratingtext
  		case self.rating
			when -3
				"Awaiting Inspection"
			when -2
				"Excluded"
  		when -1
  			"Supplies food direct to customers but is not rated on the basis that it is 'low risk' and consumers would not generally recognise is as being a food business"
  		when 0
  			"Urgent improvement necessary"
  		when 1
  			"Major improvement necessary"
  		when 2
  			"Improvement necessary"
  		when 3
  			"Generally satisfactory"
  		when 4
  			"Good"
  		when 5
  			"Very good"
  		end
  	end

		def not_rated?
			self.rating < 0
		end

  	def getrating
  		stars = self.hygiene + self.structure + self.confidence

		if stars >=0 and stars <=15
			if hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			elsif hygiene > 15 or structure > 15 or confidence > 15
				rating = 1
			elsif hygiene > 10 or structure > 10 or confidence > 10
				rating = 2
			elsif hygiene > 5 or structure > 5 or confidence > 5
				rating = 4
			else
				rating = 5
			end
		elsif stars >=16 and stars <=20
			if hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			elsif hygiene > 15 or structure > 15 or confidence > 15
				rating = 1
			elsif hygiene > 10 or structure > 10 or confidence > 10
				rating = 2
			else
				rating = 4
			end
		elsif stars >=21 and stars <=30
			if hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			elsif hygiene > 15 or structure > 15 or confidence > 15
				rating = 1
			elsif hygiene > 10 or structure > 10 or confidence > 10
				rating = 2
			else
				rating = 3
			end
		elsif  stars >=31 and stars <=40
			if hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			elsif hygiene > 15 or structure > 15 or confidence > 15
				rating = 1
			else
				rating = 2
			end
		elsif  stars >=41 and stars <=50
			if hygiene > 20 or structure > 20 or confidence > 20
				rating = 0
			else
				rating = 1
			end
		elsif  stars > 50
			rating = 0
		end

		self.update_attributes(:rating => rating)
  		self.save

		return rating
  	end

  	def buffer(now = false)
  		if self.rating >= 0
  			text = "New Inspection: #{self.name} #{self.town} #{self.rating}/5 #{"http://www.ratemyplace.org.uk/inspections/" + self.slug}"
  		else
  			text = "New Inspection: #{self.name} #{self.town} Exempt #{"http://www.ratemyplace.org.uk/inspections/" + self.slug}"
  		end
  		BufferApp.new(BUFFER_CONFIG[:token], BUFFER_CONFIG[:id]).create(text, now)
  	end

  	def reportsize
  		size = self.report.size / 1000
  		return size.to_s + "kb"
  	end

  	def lodgeappeal(date = Time.new)
  		date = date.strftime("%e %B %Y").strip
  		council = Council.find(self.councilid)
  		system "PHANTOMJS_EXECUTABLE=\"/usr/local/bin/phantomjs\" /usr/local/bin/casperjs lib/lodgeappeal.js #{FSA_CONFIG[:url]} #{"%03d" % council.fsaid} #{council.username} #{council.password} #{self.id} \"#{date}\""
  	end

  	def rejectappeal(date = Time.new)
  		date = date.strftime("%e %B %Y").strip
  		council = Council.find(self.councilid)
  		system "PHANTOMJS_EXECUTABLE=\"/usr/local/bin/phantomjs\" /usr/local/bin/casperjs lib/acceptrejectappeal.js #{FSA_CONFIG[:url]} #{"%03d" % council.fsaid} #{council.username} #{council.password} #{self.id} \"#{date}\" reject"
  	end

  	def acceptappeal(date = Time.new)
  		date = date.strftime("%e %B %Y").strip
  		council = Council.find(self.councilid)
  		system "PHANTOMJS_EXECUTABLE=\"/usr/local/bin/phantomjs\" /usr/local/bin/casperjs lib/acceptrejectappeal.js #{FSA_CONFIG[:url]} #{"%03d" % council.fsaid} #{council.username} #{council.password} #{self.id} \"#{date}\" reject"
  		#todo - upload the latest fsa xml file - might be best to schedule this???
  	end

    def in_appeals_period?
      appeal != true && published == false && (Date.today - Inspection.last.date).to_i <= 35
    end

		def private?
			["Included and Private", "Exempt and Private", "Awaiting Inspection and Private"].include?(self.scope)
		end

end
