require 'bitly'

class UrlShortener

	def self.shorten(url)
		Bitly.use_api_version_3
		bitly = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])

		bitly.shorten(url)
	end

end
