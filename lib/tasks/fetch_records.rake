namespace :axxo do
  require 'nokogiri'
  require 'open-uri'
  task :fetch_records => :environment do
    doc = Nokogiri::HTML(open("http://axxomovies.org")) # fetching page 1, pero redandunt pa 
    doc.css("div.post").each do |post|
      title = post.css(".post-title").text
      link = post.at_css("a").attributes["href"].value
      image = post.at_css("img").attributes["src"].value
      genre = post.css(".cats").children.collect { |x| x.name == "a" ? x.text : ""}.reject(&:blank?)
      
      movie = Movie.find_or_create_by(title: title)
      movie.link = link
      movie.save!
      print "."
    end
  end
end
