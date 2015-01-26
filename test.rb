require 'uri'

a = URI.parse("hello")
#a = URI.parse("http://www.omdbapi.com?t=7 Faces of Dr.Lao&y=1964&type=movie")
a = URI.parse(URI.encode('http://www.omdbapi.com?t=7 Faces of Dr.Lao&y=1964&type=movie'))
puts a.class
