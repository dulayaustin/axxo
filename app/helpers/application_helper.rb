module ApplicationHelper
  include Ransack::Helpers::FormHelper

  def genre_status(status)
    if ["horror", "drama", "action", "sports"].include?(status.downcase)
      klass = "danger"
    elsif ["adventure", "animation", "biography", "thriller"].include?(status.downcase)
      klass = "warning"
    elsif ["comedy", "crime", "documentary", "war"].include?(status.downcase)
      klass = "info"
    elsif ["family", "fantasy", "music", "western"].include?(status.downcase)
      klass = "success"
    elsif ["mystery", "romance", "sci-fi"].include?(status.downcase)
      klass = "primary"
    else
      klass = "default"
    end

    content_tag :span, class: "label label-#{klass}" do
      status.titleize
    end    
  end

  def embed(url)
    youtube_url = url.split("?").first
    content_tag(:iframe, nil, src: "#{youtube_url}", allowfullscreen: "true", class: "embed-responsive-item")
  end

  def info_value(info)
    if (!info.nil?)
      content_tag(:span, info)
    else
      content_tag(:span, "None")
    end
  end

end
