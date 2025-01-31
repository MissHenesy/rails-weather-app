module MockLocationData

  VALID_ZIP_CODE = '12946'
  def mock_location_data
    {
      lat: '44.279491',
      lng: '-73.979871', 
      city: 'Lake Placid', 
      state: 'NY', 
      zip_code: VALID_ZIP_CODE
    }
  end
end
