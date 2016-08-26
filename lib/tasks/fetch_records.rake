namespace :axxo do
  require 'nokogiri'
  require 'open-uri'

  desc "Populate Movie table with title and link field, then genre to MovieCategory table from axxomovies.org"
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

  desc "Populate Movie table with image, torrent, plot, youtube_url and info fields from specific movie link"
  task :get_specific_details => :environment do 
    Movie.find_each do |movie|
      details = Nokogiri::HTML(open(movie.link))
      details.css("div.post").each do |post|
        image = post.at_css("img").attributes["src"].value
        torrent = post.css("p").at_css("a").attributes["href"].value
        youtube_url = post.at_css("iframe").attributes["src"].value
        p_align = post.css("p[align='left']")
        p_text_align = post.css("p[style='text-align: left;']")

        if (!p_align.first.nil? && !p_align.last.nil?)   # root page to page 15
          plot = p_align.first.text
          plot.slice!(0, 6)
          info = p_align.last.text
          imdb_link = p_align.last.at_css("a").attributes["href"].value

        elsif (!p_text_align.first.nil? && !p_text_align.last.nil?)   # specific movie from pages 16 and above
          plot = p_text_align.first.text    # problem on page 16 http://axxomovies.org/predator-dark-ages-2015/
          plot.slice!(0, 6)
          info = p_text_align.last.text
          imdb_link = p_text_align.last.at_css("a").attributes["href"].value

        elsif (!post.css("p").at_css("strong").nil? && post.css("p").at_css("strong").text != "Tags: ") 
          plot = post.css("p").at_css("strong").text        # page 1200 http://axxomovies.org/hit-list-2011/
          plot = plot.reverse!
          end_index = plot.index(".")
          plot.slice!(0, end_index)
          plot = plot.reverse!
        else
          plot = post.css("p").text.delete!("\n")   # last page http://axxomovies.org/win-win-2011/
          plot = plot.reverse!            #
          end_index = plot.index(".")     #  page 1000 http://axxomovies.org/chernobyl-diaries-2012/
          plot.slice!(0, end_index)       # 
          plot = plot.reverse!            #
        end

        if info           ## pages 1000 and above, no info included
          info = info.split("\n")
          imdb_text = info.shift
          genre_text = info.shift
          size = info.shift
          size.slice!(0, 6)
          quality = info.shift
          quality.slice!(0, 9)
          language = info.shift
          language.slice!(0, 10)
        end

        movie.image = image
        movie.torrent = torrent
        movie.plot = plot
        movie.youtube_url = youtube_url
        movie.imdb = imdb_link
        movie.size = size
        movie.quality = quality
        movie.language = language
        movie.save!

        print "."
      end
    end
  end
end
