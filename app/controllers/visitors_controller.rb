class VisitorsController < ApplicationController
  before_action :set_movie, only: :display
  def index
    doc = Nokogiri::HTML(open("http://axxomovies.org/hugo-2011"))
    doc.css("div.post").each do |post|
      image = post.at_css("img").attributes["src"].value
      torrent = post.css("p").at_css("a").attributes["href"].value
      youtube_url = post.at_css("iframe").attributes["src"].value
      p_align = post.css("p[align='left']")
      p_text_align = post.css("p[style='text-align: left;']")
      p_style_color = post.css("p[style='color: #666666; text-align: left;']")

      if ((!p_align.first.nil?) && (!p_align.last.nil?))   # root page to page 15
        plot = p_align.first.text
        plot.slice!(0, 6)
        info = p_align.last.text
        imdb_link = p_align.last.at_css("a").attributes["href"].value

      elsif ((!p_text_align.first.nil?) && (!p_text_align.last.nil?))   # specific movie from pages 16 and above
        if (p_text_align.first.text == "SHORT MOVIE") # page 16 http://axxomovies.org/predator-dark-ages-2015/
          plot = p_text_align[1].text.strip
          plot.slice!(0, 6)
        else
          if (!p_text_align.first.text.blank?)
            plot = p_text_align.first.text.strip
            plot.slice!(0, 6)

          elsif (!p_text_align[1].text.blank?)
            plot = p_text_align[1].text.strip
            plot.slice!(0, 6)
          else
            plot = p_text_align[2].text.strip
            plot.slice!(0, 6)
          end
        end

        if p_style_color.last
          info = p_style_color.last.text    # http://axxomovies.org/warrior-princess-2014/
        else
          info = p_text_align.last.text
        end

        if (!p_text_align.last.at_css("a").nil?)        # http://axxomovies.org/retreat-2011/         
          imdb_link = p_text_align.last.at_css("a").attributes["href"].value
        end

      elsif ((!p_style_color.first.nil?) && (!p_style_color.last.nil?))
        plot = p_style_color.first.text.strip
        plot.slice!(0, 6)
        info = p_style_color.last.text
        imdb_link = p_style_color.last.at_css("a").attributes["href"].value

      else
        p_elements = post.css("p")
        p_first = p_elements.first.text
        p_second = p_elements[1].text
        p_third = p_elements[2].text

        p_first = p_first.delete("\n").strip
        p_second = p_second.delete("\n").strip
        p_third = p_third.delete("\n").strip

        if (!p_first.blank?)
          plot = p_first        

        elsif (!p_second.blank?)
          plot = p_second       

        elsif (!p_third.blank?) # http://axxomovies.org/hugo-2011
          plot = p_third

        elsif (!post.at_css("pre").nil?)  # http://axxomovies.org/treasure-island-2012/
          plot = post.at_css("pre").text.split(" ")
          plot = plot.join(" ")      

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
        language = language.split(":")
        language.shift
        language = language.last.strip
      end 
      dsa.dsa
    end
  end

  def display
    
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end
end
