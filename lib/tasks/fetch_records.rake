namespace :axxo do
  require 'nokogiri'
  require 'open-uri'

  desc "Populate Movie table with title and link field, then genre to MovieCategory table from axxomovies.org"
  task fetch_records: :environment do
    doc = Nokogiri::HTML(open("http://axxomovies.org/page/20/"))
    last_page = doc.css("div.wp-pagenavi").css('a').last.attributes["href"].value
    last_page = last_page.split("/")
    last_page = last_page.last.to_i
    last_page.downto(2) do |page_number|
      movie = MovieScrape.new("http://axxomovies.org/page/#{page_number}/")
      movie.fetch
      print "."
    end

    movie = MovieScrape.new("http://axxomovies.org")
    movie.fetch
    print "."
  end

  desc "Populate Movie table in newest movies"
  task fetch_newest_records: :environment do
    50.downto(2) do |page_number|
      movie = MovieScrape.new("http://axxomovies.org/page/#{page_number}/")
      movie.fetch
      print "."
    end

    movie = MovieScrape.new("http://axxomovies.org")
    movie.fetch
    print "."
  end

  desc "Populate Movie table with image, torrent, plot, youtube_url and info fields from specific movie link"
  task get_specific_details: :environment do 
    Movie.pending.find_each do |movie|
      begin
        movie.get_specific_details!
        movie.has_information?
        movie.save!
        print "."
      rescue
        print "F"
      end
    end
  end

  desc "Modify error Movie link"
  task trim_movie_error_links: :environment do
    Movie.pending.find_each do |movie|
      movie.trim_link
      movie.valid_url?
      movie.save!
      print "."
    end
  end
end
