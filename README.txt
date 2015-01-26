Kristofer Ken Castro
1/23/2015
Bookbub Challenge

-------------------------------------------------
Dependencies
-------------------------------------------------
Ruby 2.20 
Rspec

-------------------------------------------------
How to run
-------------------------------------------------
you run it through the terminal

"ruby Solution.rb [csv input file] [output file] [number of threads]"

ex.  ruby Solution.rb movies.csv output.txt 5 

The input is movies.csv
The output will be written to output.txt
The maximum number of threads that requests the OMDB Web API is 5

note: Setting the thread count too high may cause a refuse connection, if it does, set it lower!

---------------------------------------------------
Cases considered
---------------------------------------------------
+ Since we are outputting in the format of [movie] -- [rating] there are some movies that
  are either not found or not yet available.  Not yet rated movies  return a "N/A" for their
  imdb rating.  Not found movies return nil.
  
  I output them as follows:
  
  1.  Not available:  "[movie] -- N/A]"
  2.  Not found : "[movie] -- not found"

+ Since their may be movies titles that might conflict with non-movie types like TV episodes
  I made use of the OMDB Api parameter "type=movie"

+ Some movie titles may contain characters that gave me troubles using Ruby's URI class,
  I made sure to replace all characters that is not part of the 127 bits of ascii with an empty character.

  Regex: /[^\u0000-\u007F]/  notice 007F is just 0000 0000 0111 11111 = 2^7 = 127 bits 

+ Also, there is some titles that when I search in IMDB I can find it under a different or similar name
  but when I search using OMDB api, I can't seem to gethe right one.  For example, "20 Feet from Stardom"
  the 2013 movie title can't be found using OMDB api.  Also the movie title Arthur Rubinstein - The Love of Life
  can be found if you look at imdb.com but not through the API.  Perhaps it is the fault of the API.

+ Some cases considered 
  1.  Duplicate movie title but different years
  2.  Movie titles that are empty strings
-----------------------------------------------------
General Algorithm
-----------------------------------------------------
Since we know that IMDB has a 0.0 to 10.0 rating system.
All rating values can be said to be between 0 and 100.

This is perfect since we can make an array of size 100 containing movie titles.
We can then proceed to use a Counting Sort algorithm to get linear time complexity O(n)
to sort by imdb rating.  Note: to get the actual rating we divide the index/10.0

1. Create array of size 100 called A
2. Get all imdb ratings for each movie title in the csv file and place them in the appropriate
   index A[rating*10] (notice we are multiplying by 10 since we are using index 0 to 100 to
   represent ratings 0.0 to 10.0)
3. Once done, simply output the array in reverse order A[100] all the way to A[0].
   Each index in the array A is a list of movies that has index/10.0 rating

Time complexity: O(n)
Space complexity: O(n)

The specification didn't say that we should sort by title as well for each rating but
you can do a separate comparison sorting algorithm in each of the movie list in each
index like the likes of merge sort, heap sort, quick sort.  

-------------------------------------------------------
Some useful terminal commands to view certain results
------------------------------------------------------

1. List all movies found to have no rating:  less output.txt | grep "N/A" 
2. List all movies that was not found : less output.txt | grep "not found"
3. List all rated movies: less out.put.txt | grep "[0-9].[0-9]$"
4. List all movies rated at 9.2: less output.txt | grep "9.2$"
