require 'nokogiri'
require 'open-uri'


class Movie < ActiveRecord::Base
  has_many :movie_categories
  has_many :categories, through: :movie_categories, source: :category

  scope :without_torrent, -> {where(torrent: nil)}


  def get_specific_details!
    return if torrent.present?
    self.image = get_source_image
    self.torrent = get_source_torrent
    self.youtube_url = get_source_youtube_url
    self.save!
  end

  def get_source_image
    entry.at_css("img").attributes["src"].value
  end

  def get_source_torrent
    entry.css("p").at_css("a").attributes["href"].value
  end

  def get_source_youtube_url
    entry.at_css("iframe").attributes["src"].value
  end


  def has_information?
    # add logic in here
  end


  def document
    @document ||= Nokogiri::HTML(open(self.link))
  end

  def entry
    @entry ||= document.css("div.entry")
  end




end
