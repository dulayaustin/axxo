module ApplicationHelper

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

    content_tag :div, class: "label label-#{klass}" do
      status.titleize
    end    
  end

  def description(info)
    info.split("\n")
  end

  def embed(url)
    youtube_url = url.split("?").first
    content_tag(:iframe, nil, src: "#{youtube_url}", allowfullscreen: "true")
  end

end
