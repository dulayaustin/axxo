class VisitorsController < ApplicationController

  def index
    @movies = Hash.new   
    #@movies_array = []
    (2..10).each do |page_number|    
      doc = Nokogiri::HTML(open("http://axxomovies.org/page/#{page_number}/"))
      doc.css("div.post").each do |post|
        title = post.css(".post-title").text
        link = post.at_css("a").attributes["href"].value
        image = post.at_css("img").attributes["src"].value
        genre = post.css(".cats").children.collect { |x| x.name == "a" ? x.text : ""}.reject(&:blank?)

        @movies[title] = Hash.new
        @movies[title][:link] = link
        @movies[title][:genre] = genre

        #@movies_array << @movies        
      end
    end
    
    #@movies_array = Kaminari.paginate_array(@movies_array).page(params[:page]).per(3)
  end

  def display
    url = params[:link]
    details = Nokogiri::HTML(open(url))
    @title = details.css("div.post").at_css(".post-title").text
    @image = details.css("div.post").at_css("img").attributes["src"].value
    @torrent = details.css("div.post").css("p").at_css("a").attributes["href"].value
  end
end
