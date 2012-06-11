class BufferApp
	include HTTParty
	base_uri 'https://api.bufferapp.com/1'
		
	def initialize(token, id)
		@token = token
		@id = id
	end
	
	def profiles
		BufferApp.get('/profiles.json', :query => {"access_token" => @token}).parsed_response
	end
	
	def pending
		BufferApp.get("/profiles/#{@id}/updates/pending.json", :query => {"access_token" => @token}).parsed_response
	end
	
	def sent
		BufferApp.get("/profiles/#{@id}/updates/sent.json", :query => {"access_token" => @token}).parsed_response
	end

	def create(text, now = false)
		if now === false
			BufferApp.post('/updates/create.json', :body => {"text" => text, "profile_ids[]" => @id, "access_token" => @token}).parsed_response
		else
			BufferApp.post('/updates/create.json', :body => {"text" => text, "profile_ids[]" => @id, "access_token" => @token, "now" => "true"}).parsed_response
		end
	end	
end

