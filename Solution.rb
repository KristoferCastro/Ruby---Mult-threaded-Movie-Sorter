require './Omdb_api'
require './Movie'
require 'csv'
# Since we are sorting by IMDB rating and IMDB rating goes from 
# 0.0 to 10.0 with 1 decimal point accuracy, we can use an algorithm
# such as "Counting Sort" having index value from 0 to 100.
#
# For example, consider an array of 101 elements (0 to 100)
# 
# A[100]
# .
# . 
# A[90] = ["Dark Knight", Movie2,....MovieK]
# A[89] = [Movie123, Movie493]   
#    
# The rating is actually the index/10.0.  For example, index 90 = 90/10.0 = 9.0
#
# ----------------------
# Complexity Analysis:
# -----------------------
# Time: O(n) since it takes O(1) to find the right index and their are n movies
# Space: O(n) since we need to store all movies into the Hash
class Solution
  attr_accessor :ratings_hash
  
  #@@max_threads = 4 # used for OMDB Api request
  
  def initialize(csv_filename, output_filename, max_threads)
    
    # This is the array of movies where the index is the rating
    @ratings_hash = [] # store movies that are rated
    @not_rated_list = [] # store movies that has not been rated yet i.e. "N/A"
    @not_found_list = [] # store movie titles not found
    
    @max_threads = max_threads.to_i

    101.times do |i| @ratings_hash[i] = [] end
    
    # if the user did not provide the extension, attach it
    csv_filename += ".csv" unless csv_filename.end_with? ".csv" 
    @csv_filepath = "./#{csv_filename}"
    
    @output_filename = output_filename
    @output_filename += ".txt" unless @output_filename.end_with? ".txt"
    
    process_file() 
    write_output()
  end

  # Multi-threaded algorithm to handle multiple get request
  # to the OMDB Web API.  Follows a Thread Pooling
  # design pattern.  
  def process_file 
     
     csv_hash = {} 
     CSV.foreach(@csv_filepath) do |row|
       title = row[0]
       year = row[1]
       csv_hash[title] = [] if csv_hash[title] == nil
       csv_hash[title] << Movie.new(title, year)
     end
       
     # create a work queue and add all the movies to it
     work_q = Queue.new 
     csv_hash.each do |title, movieList| 
       movieList.each do |movie| work_q.push(movie) end 
     end
     
     # create array of thread workers that grabs imdb rating from OMDB api
     workers =  (0...@max_threads).map do 
       Thread.new do
         begin
           while movie = work_q.pop(true) 
             concurrent_request_get_rating(movie.title, movie.year)
           end
         rescue ThreadError
         end 
       end
     end
     # make sure each thread terminates before closing the program
     workers.map(&:join)    
  end
  
  def write_output
    output = ""
    index = 100
    @ratings_hash.reverse_each do |movieList|
      currentRating = index/10.0
      movieList.each do |movie| output << "#{movie} -- #{currentRating}\n" end
      index -=1
    end

    @not_rated_list.each do |movie| output << "#{movie} -- N/A\n" end
    @not_found_list.each do |movie| output << "#{movie} -- not found\n" end
    output.chop! # remove the last \n
    output_file = File.open(@output_filename, "w") do |file|
      file.puts output
    end
  end

  def print_ratings 
     index = 100
     @ratings_hash.reverse_each do |movieList|
       currentRating = index/10.0
       movieList.each do |movie| puts "#{movie} -- #{currentRating}" end
       index -= 1
     end
     
     @not_rated_list.each do |movie| puts "#{movie} -- N/A" end
     @not_found_list.each do |movie| puts "#{movie} -- not found" end
  end

  # Get data from OMDB servers 
  def concurrent_request_get_rating(title, year)
    api = Omdb_api.new
    rating = api.get_imdb_rating(title, year)
    puts "imdb: \t #{rating} \t receieved for #{title}(#{year})"
    
    if rating == nil
      @not_found_list << title 
    elsif rating.casecmp("N/A").zero?
      @not_rated_list << title
    else
      @ratings_hash[rating.to_f*10].push(title)
    end
  end

end

unless ARGV.length == 2 || ARGV.length == 3
  puts "Requires two arguments: the input csv filename and output filename"
  puts "Example: Solution mycsv.csv output.txt"
  exit
end

csv_filename = ARGV[0]
output_filename = ARGV[1]
max_threads = ARGV[2] || 1
sol = Solution.new(csv_filename, output_filename, max_threads)


