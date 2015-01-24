# This class represents a Movie object
class Movie
  attr_reader :title, :year
  attr_accessor :imdb_rating
  def initialize(title, year)
    @title = title
    @year = year
    @imdb_rating = nil
  end
end

