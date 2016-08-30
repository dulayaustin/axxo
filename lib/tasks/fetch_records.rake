namespace :axxo do
  require 'nokogiri'
  require 'open-uri'

  desc "Populate Movie table with first 3 newest movie"
  task fetch_new_records: :environment do
    movie = MovieScrape.new("http://axxomovies.org")
    movie.fetch
  end

  desc "Populate Movie table with title and link field, then genre to MovieCategory table from axxomovies.org"
  task fetch_all_old_records: :environment do
    doc = Nokogiri::HTML(open("http://axxomovies.org/page/20/"))
    last_page = doc.css("div.wp-pagenavi").css('a').last.attributes["href"].value
    last_page = last_page.split("/")
    last_page = last_page.last.to_i
    last_page.downto(2) do |page_number|
      movie = MovieScrape.new("http://axxomovies.org/page/#{page_number}/")
      movie.fetch
      print "."
    end
  end

  desc "Populate Movie table with image, torrent, plot, youtube_url and info fields from specific movie link"
  task get_specific_details: :environment do 
    Movie.without_info.find_each do |movie|
      doc = Nokogiri::HTML(open(movie.link))
      doc.css("div.post").each do |post|
        begin
          image = post.at_css("img").attributes["src"].value
          torrent = post.css("p").at_css("a").attributes["href"].value
          youtube_url = post.at_css("iframe").attributes["src"].value
          p_align = post.css("p[align='left']")
          p_text_align = post.css("p[style='text-align: left;']")

          if ((!p_align.first.nil?) && (!p_align.last.nil?))   # root page to page 15
            plot = p_align.first.text
            plot.slice!(0, 6)
            info = p_align.last.text
            imdb_link = p_align.last.at_css("a").attributes["href"].value

          elsif ((!p_text_align.first.nil?) && (!p_text_align.last.nil?))   # specific movie from pages 16 and above
            if (p_text_align.first.text == "SHORT MOVIE") # page 16 http://axxomovies.org/predator-dark-ages-2015/
              plot = p_text_align[1].text
              plot.slice!(0, 6)
            else
              plot = p_text_align.first.text
              plot.slice!(0, 6)
            end

            if (!p_text_align.last.at_css("a").nil?) # http://axxomovies.org/retreat-2011/
              info = p_text_align.last.text                 
              imdb_link = p_text_align.last.at_css("a").attributes["href"].value
            end

          else
            plot = post.css("p")

            if (!plot.first.text.delete("\n").empty?)
              plot = plot.first.text.delete("\n")        

            elsif (!plot[1].text.delete("\n").empty?)
              plot = plot[1].text.delete("\n")       

            elsif (!plot[2].text.delete("\n").empty?)
              plot = plot[2].text.delete("\n")      

            else                           
              plot = post.css("div")[5].text.delete("\n")    # http://axxomovies.org/colombiana-2011-2/                                                 
            end
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
        rescue
          print "F"
        end
      end
    end
  end
end
