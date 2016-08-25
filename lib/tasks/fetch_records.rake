namespace :axxo do
  require 'nokogiri'
  require 'open-uri'

  desc "Migrate title, link and genre from axxomovies.org to Movie table"
  task :fetch_records => :environment do
    doc = Nokogiri::HTML(open("http://axxomovies.org")) 
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
      print "."
    end
  end

  desc "Migrate image, torrent, plot, youtube_url and specific description from from specific movie to Movie table"
  task :get_specific_details => :environment do 
    Movie.find_each do |movie|
      details = Nokogiri::HTML(open(movie.link))
      details.css("div.post").each do |post|
        image = post.at_css("img").attributes["src"].value
        torrent = post.css("p").at_css("a").attributes["href"].value
        youtube_url = post.at_css("iframe").attributes["src"].value

        if (!post.css("p[align='left']").first.nil? && !post.css("p[align='left']").last.nil?)
          plot = post.css("p[align='left']").first.text
          info = post.css("p[align='left']").last.text

        elsif(!post.css("p[style='text-align: left;']").first.nil? && !post.css("p[style='text-align: left;']").last.nil?)
          plot = post.css("p[style='text-align: left;']").first.text
          info = post.css("p[style='text-align: left;']").last.text
        end
        
        # modify IMDB link for other pages

        movie.image = image
        movie.torrent = torrent
        movie.plot = plot
        movie.youtube_url = youtube_url
        movie.save!

        info = info.split("\n")
        imdb = info.shift
        imdb.slice!(0, 11)
        genre = info.shift
        size = info.shift
        size.slice!(0, 6)
        quality = info.shift
        quality.slice!(0, 9)
        language = info.shift
        language.slice!(0, 10)

        Description.find_or_create_by(movie_id: movie.id, imdb: imdb, size: size, quality: quality, language: language)
        print "."
      end
    end
  end
end
