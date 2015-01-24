require 'net/http'

# 
# This class handles communication with the OMDB api through HTTP 
#
class Omdb_api

  @@hostname = 'http://www.omdbapi.com/?'

  public
  
  def initialize
    initialize_parameters()
  end

  def get_imdb_rating(title = nil, year = nil)
    if title == nil then raise 'You need to input a title' end 
   
    # Regex says all uni code not in the range of  0 to 127 should be deleted!
    title = title.gsub(/[^\u0000-\u007F]/, "") # this fixes cases with non-ascii characters  
    
    params = { t: title, y: year }
    request_uri = make_request_uri(params) 
    recieved_data = send_request(request_uri) 
    rating = recieved_data[:imdbRating]
    #test_input = "imdb:\t#{rating} \t #{title}(#{year}) ...#{request_uri.to_s}"
    #puts test_input
    return rating
   end

  
  # Send the request to OMDB API and return the JSON data
  # represented as a Ruby Hash
  def send_request(uri)
    resp = Net::HTTP.get_response(uri) 
    data = eval(resp.body) # convert the JSON string to Ruby Hash
    return data
  end 

  # The params is a Hash of expected valid omdb params
  # with its associated value.  Throws an exception
  # if not a valid omdb paramter.
  #
  # ex.  make_request_url ( { t: 'Dark Knight', y: 2011} )
  # 
  # This function will return the URL for the request
  # 
  # ex.  http://www.omdbapi.com/?t=Dark%20Knight&y=2011
  def make_request_uri(params)
    request_url = @@hostname
    
    params[:type] = "movie" #ignore non-movie titles!
  
    params.each do | param, value |
      raise "#{param} is not a valid omdb parameter" unless @omdb_params.include?(param)
      request_url += "#{param}=#{value}&"  
    end
    request_url = request_url.chop # remove the last &
    return URI.parse(request_url)
  end

  private
  
  # Parameters
  # List all the valid omdb parameters
  def initialize_parameters
    @omdb_params = [:i, :t, :type, :y, :plot, :r, :tomates, :callback, :v, :s] 
  end
end
