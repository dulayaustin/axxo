namespace :axxo do
  require 'nokogiri'
  require 'open-uri'

  desc "Populate Movie table with first 3 newest movie"
  task fetch_new_records: :environment do
    movie = MovieScrape.new("http://axxomovies.org")
    movie.fetch

    print "."
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
    Movie.without_torrent.find_each do |movie|
      movie.get_specific_details!

      # doc = Nokogiri::HTML(open(movie.link))
      # doc.css("div.post").each do |post|
      #   begin
      #     image = post.at_css("img").attributes["src"].value
      #     torrent = post.css("p").at_css("a").attributes["href"].value
      #     youtube_url = post.at_css("iframe").attributes["src"].value
      #     p_align = post.css("p[align='left']")
      #     p_text_align = post.css("p[style='text-align: left;']")
      #     p_style_color = post.css("p[style='color: #666666; text-align: left;']")

      #     if ((!p_align.first.nil?) && (!p_align.last.nil?))   # root page to page 15
      #       plot = p_align.first.text
      #       plot.slice!(0, 6)
      #       info = p_align.last.text
      #       imdb_link = p_align.last.at_css("a").attributes["href"].value

      #     elsif ((!p_text_align.first.nil?) && (!p_text_align.last.nil?))   # specific movie from pages 16 and above
      #       if (p_text_align.first.text == "SHORT MOVIE") # page 16 http://axxomovies.org/predator-dark-ages-2015/
      #         plot = p_text_align[1].text.strip
      #         plot.slice!(0, 6)
      #       else
      #         if (!p_text_align.first.text.blank?)
      #           plot = p_text_align.first.text.strip
      #           plot.slice!(0, 6)
      #           info = p_text_align[1].text
      #           imdb_link = p_text_align.at_css("a").attributes["href"].value

      #         elsif (!p_text_align[1].text.blank?)
      #           plot = p_text_align[1].text.strip
      #           plot.slice!(0, 6)
      #           info = p_text_align.last.text
      #           imdb_link = p_text_align.at_css("a").attributes["href"].value

      #         else
      #           plot = p_text_align[2].text.strip
      #           plot.slice!(0, 6)
      #           info = p_text_align.last.text
      #           imdb_link = p_text_align.at_css("a").attributes["href"].value
      #         end
      #       end

      #       if p_style_color.last
      #         info = p_style_color.last.text    # http://axxomovies.org/warrior-princess-2014/
      #         imdb_link = p_style_color.last.at_css("a").attributes["href"].value   # http://axxomovies.org/beyond-the-edge-2013/
      #       end


      #       if (!p_text_align.last.at_css("a").nil?)        # http://axxomovies.org/retreat-2011/         
      #         imdb_link = p_text_align.last.at_css("a").attributes["href"].value
      #       end

      #     elsif ((!p_style_color.first.nil?) && (!p_style_color.last.nil?))
      #       plot = p_style_color.first.text.strip
      #       plot.slice!(0, 6)
      #       info = p_style_color.last.text
      #       imdb_link = p_style_color.last.at_css("a").attributes["href"].value

      #     else
      #       p_elements = post.css("p")
      #       p_first = p_elements.first.text
      #       p_second = p_elements[1].text


      #       p_first = p_first.delete("\n").strip
      #       p_second = p_second.delete("\n").strip

      #       if (!p_first.blank?)
      #         plot = p_first        

      #       elsif (!p_second.blank?)
      #         plot = p_second       

      #       elsif (!p_elements[2].blank?) # http://axxomovies.org/hugo-2011
      #         plot = p_elements[2].text
      #         plot = plot.delete("\n").strip

      #       elsif (!post.at_css("pre").nil?)  # http://axxomovies.org/treasure-island-2012/
      #         plot = post.at_css("pre").text.split(" ")
      #         plot = plot.join(" ")      

      #       else                           
      #         plot = post.css("div")[5].text.delete("\n")    # http://axxomovies.org/colombiana-2011-2/                                                 
      #       end
      #     end

      #     if info           ## pages 1000 and above, no info included
      #       info = info.split("\n")
      #       imdb_text = info.shift
      #       genre_text = info.shift
      #       size = info.shift
      #       size.slice!(0, 6)
      #       quality = info.shift
      #       quality.slice!(0, 9)
      #       language = info.shift
      #       language = language.split(":")
      #       language.shift
      #       language = language.last.strip
      #     end 

      #     movie.image = image
      #     movie.torrent = torrent
      #     movie.plot = plot
      #     movie.youtube_url = youtube_url
      #     movie.imdb = imdb_link
      #     movie.size = size
      #     movie.quality = quality
      #     movie.language = language
      #     movie.save!

      #     print "."
      #   rescue
      #     print "F#{movie.id} - "
      #   end
      # end
    end
  end

  desc "Modify error Movie link"
  task trim_movie_error_links: :environment do
    Movie.without_info.find_each do |movie|
      url = movie.link.split("-")     
      url.pop
      url = url.join("-")

      movie.link = url
      movie.save!

      if movie.link.blank?
        movie.destroy
      end

      print "."
    end
  end
end
