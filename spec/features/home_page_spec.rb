require 'rails_helper'
require Rails.root.join('spec', 'support', 'request_helper')

RSpec.feature 'HomePage', type: :feature do
  let(:valid_zip_code) { '12946' }  # Valid zip code
  let(:invalid_zip_code) { '99999' }  # Invalid zip code
  let(:bad_zip_code) { 'abcde' } # Just bad input

  let(:err_invalid_zip) { 'Could not find a location for the zip code you entered. Try another one!' }
  let(:err_bad_zip) { 'Invalid postal code input.' }

  context 'when user interacts with input form', js: true do
    it 'should validate the zip code when the user presses submit' do
      mock_data = JSON.parse(File.read('./spec/fixtures/mock_transformed_location_and_weather_data.json'), symbolize_names: true)
      mock_response =  OpenStruct.new(result: mock_data)
      run_input_test(valid_zip_code, mock_response, 'Current Weather')
    end

    it 'should show an error message when input is invalid' do
      mock_response = OpenStruct.new(errors: { 'zip_code_api': [err_invalid_zip] }, result: { 'location': nil, 'weather': nil })
      run_input_test(invalid_zip_code, mock_response, err_invalid_zip)
    end

    it 'should show an error message when input is bad data' do
      mock_response = OpenStruct.new(errors: { 'zip_code_api': [err_bad_zip] }, result: { 'location': nil, 'weather': nil })
      run_input_test(bad_zip_code, mock_response, err_bad_zip)
    end
  end

  # Helper method to run input tests
  def run_input_test(zip, res, txt)
    allow(FetchLocationAndWeatherService).to receive(:call).with(zip)
      .and_return(res)

    visit root_path

    fill_in 'zip_code', with: zip
    click_button 'Get Forecast'

    expect(page).to have_content(txt)
  end
end
