require 'spec_helper'

RSpec.describe "/" do
	context "no zip" do
		it do
			get "/"

			expect(last_response.status).to eq 200
		end
	end

	context "valid zip" do
		it do
			get "/?zip_code=48415"

			expect(last_response.status).to eq 200
		end
	end

	context "zip with no data" do
		it do
			get "/?zip_code=1"

			expect(last_response.status).to eq 200
			expect(last_response.body).to include("No Data For This Zip Code")
		end
	end

	context "blank zip" do
		it do
			get "/?zip_code="

			expect(last_response.status).to eq 200
		end
	end

	context "invalid zip" do
		it do
			get "/?zip_code=a"

			expect(last_response.status).to eq 200
			expect(last_response.body).to include("Parameter 'zip' must be an integer.")
		end
	end
end