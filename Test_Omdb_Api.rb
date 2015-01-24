# RSpec Class to test the Omdb_api class

require './Omdb_api'

RSpec.describe Omdb_api  do
  
  api = Omdb_api.new
  
  expected_request = "http://www.omdbapi.com/?t=Dark%20Knight&y=2011&type=movie"
  it "Should equal to correct request URL:  #{expected_request}" do 
    params = {t: 'Dark Knight', y: '2011'} 
    result = api.make_request_uri(params)
    expect(result.to_s).to eq(expected_request)
  end

  it "Should give the imdb rating of 9.0 for The Dark Knight(2008)" do 
    expect(api.get_imdb_rating('The Dark Knight', '2008')).to eq("9.0")
  end 

end
