class AddressController < ApplicationController
	# GET /address/postcode/WS149SQ
	def postcode
		@addresses = Address.GetAddressFromPostcode(params[:postcode])
		render json: @addresses
	end
	
	def uprn
		@address = Address.GetAddressFromUprn(params[:uprn])
		render json: @address
	end
end
