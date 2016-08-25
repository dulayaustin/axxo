require 'nokogiri'
require 'open-uri'

class VisitorsController < ApplicationController

  def index
    @movie = Hash.new 
    @movies_array = Array.new
    @movies_paginate

    doc = Nokogiri::HTML(open("http://axxomovies.org")) # fetching page 1, pero redandunt pa 
    doc.css("div.post").each do |post|
      title = post.css(".post-title").text
      link = post.at_css("a").attributes["href"].value
      image = post.at_css("img").attributes["src"].value
      genre = post.css(".cats").children.collect { |x| x.name == "a" ? x.text : ""}.reject(&:blank?)
      
      @movie[title] = Hash.new
      @movie[title][:link] = link
      @movie[title][:genre] = genre
    end

    (2..10).each do |page_number|    
      doc = Nokogiri::HTML(open("http://axxomovies.org/page/#{page_number}/"))
      doc.css("div.post").each do |post|
        title = post.css(".post-title").text
        link = post.at_css("a").attributes["href"].value
        image = post.at_css("img").attributes["src"].value
        genre = post.css(".cats").children.collect { |x| x.name == "a" ? x.text : ""}.reject(&:blank?)
        
        @movie[title] = Hash.new
        @movie[title][:link] = link
        @movie[title][:genre] = genre
        

      end
      
    end
    
    @movie.each do |title, details|
      movie = Hash.new
      movie[title] = details
      @movies_array.push(movie)
    end

   
    #@movies_array = Kaminari.paginate_array(@movies_array).page(params[:page]).per(5) 
    ------ # dito ko need array, wla ako mkita hash pagination  --------
    
  end

  def display
    url = params[:link]
    details = Nokogiri::HTML(open(url))
    details.css("div.post").each do |post|
      @title = post.at_css(".post-title").text
      @image = post.at_css("img").attributes["src"].value
      @torrent = post.css("p").at_css("a").attributes["href"].value
      @plot = post.css("p[align='left']").first.text
      @imdb_link = post.css("p[align='left']").last.at_css("a").attributes["href"].value
      @info = post.css("p[align='left']").last.text
      @url = post.at_css("iframe").attributes["src"].value
    end
  end
end
