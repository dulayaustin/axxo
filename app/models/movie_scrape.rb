require 'nokogiri'
require 'open-uri'

class MovieScrape
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def fetch
    doc = Nokogiri::HTML(open(@url)) 
    doc.css("div.post").each do |post|
      title = post.css(".post-title").text
      link = post.at_css("a").attributes["href"].value
      genre = post.css(".cats").children.collect { |x| x.name == "a" ? x.text.downcase : ""}.reject(&:blank?)

      movie = Movie.find_or_create_by(title: title)
      movie.link = link
      movie.save!

      Category.where(name: genre).each do |x|
        MovieCategory.find_or_create_by(movie_id: movie.id, category_id: x.id)
      end
    end
  end
end