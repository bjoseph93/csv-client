require 'sinatra'
require 'httparty'

get '/' do
	zip_code = params[:zip_code]

	handle_response(ApiRequest.new(zip_code).get, zip_code)

	erb :index
end

def handle_response(response, zip_code)
	assign_zip_entries(response, zip_code)
	assign_message(response, zip_code)
end

def assign_zip_entries(response, zip_code)
	@zip_entries = ZipEntries.new(response, zip_code).assign_zip_entries
end

def assign_message(response, zip_code)
	@message = Message.new(response, @zip_entries, zip_code).assign_message
end

private

class ZipEntries
	def initialize(response, zip_code)
		@response = response
		@zip_code = zip_code
	end

	def assign_zip_entries
		if zip_code.to_s.empty? || !response.success?
			zip_entries = []
		else response.success?
			zip_entries = symbolize_response[:zip_entries].reject {|entry| entry[:cbsa] == 99999}
		end
	end

	private

	attr_reader :response, :zip_code

	def symbolize_response
		JSON.parse response, symbolize_names: true
	end
end

class Message
	def initialize(response, zip_entries, zip_code)
		@response = response
		@zip_code = zip_code
		@zip_entries = zip_entries
	end

	def assign_message
		if zip_code.to_s.empty?
			message = nil
		elsif !response.success? && !zip_code.to_s.empty?
			message = response.to_json
		else
			if zip_entries.empty?
				message = "No Data For This Zip Code"
			end
		end
	end

	private

	attr_reader :response, :zip_entries, :zip_code

end

class ApiRequest
	def initialize(zip_code)
		@zip_code = zip_code
	end

	def get
		HTTParty.get("https://ben-joseph-peerstreet-api.herokuapp.com/zip_codes?zip=#{zip_code}", format: :plain)
	end

	private

	attr_reader :zip_code
end