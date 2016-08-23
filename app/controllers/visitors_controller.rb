

class VisitorsController < ApplicationController

  def index
    @movies = Hash.new   
    @movies_array = []
    (2..5).each do |page_number|    
      doc = Nokogiri::HTML(open("http://axxomovies.org/page/#{page_number}/"))
      doc.css("div.post").each do |post|
        title = post.css(".post-title").text
        link = post.at_css("a").attributes["href"].value
        image = post.at_css("img").attributes["src"].value

        @movies[title] = Hash.new
        @movies[title][image] = link

        @movies_array << @movies        
      end
    end

    @movies_array = Kaminari.paginate_array(@movies_array).page(params[:page]).per(3)
  end

  # def display
  #   url = params[:link]
  #   page = Nokogiri::HTML(open(url))
   
  # end
end
