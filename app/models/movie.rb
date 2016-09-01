require 'nokogiri'
require 'open-uri'


class Movie < ActiveRecord::Base
  has_many :movie_categories
  has_many :categories, through: :movie_categories, source: :category

  scope :without_torrent, -> {where(torrent: nil)}
  scope :pending, ->{where(status: "pending")}


  def get_specific_details!
    return if torrent.present?
    self.image = get_source_image
    self.torrent = get_source_torrent
    self.youtube_url = get_source_youtube_url
    self.status = "passed"
    self.save!
  end

  def get_source_image
    entry.at_css("img").attributes["src"].value
  end

  def get_source_torrent
    if (!entry.css("p").at_css("a").attributes["href"].nil?)
      torrent = entry.css("p").at_css("a").attributes["href"].value
    else
      torrent = entry.css("p").css("a")[2].attributes["href"].value
    end
  end

  def get_source_youtube_url
    entry.at_css("iframe").attributes["src"].value
  end

  def has_information?
    self.plot = get_source_plot
    self.imdb = get_source_imdb
    self.size = get_source_size
    self.quality = get_source_quality
    self.language = get_source_language
    self.save!
    
  end

  def get_source_plot
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.present?        
      if p_align.first.text.include?("Plot")
        plot = extract_plot("p[align='left']", "first")

      elsif p_align[1].text.include?("Plot")
        plot = extract_plot("p[align='left']", 1)

      else
        return plot if plot.present?
      end

    elsif p_style_text_align.present?                
      if p_style_text_align.first.text.include?("Plot")
        plot = extract_plot("p[style='text-align: left;']", "first")

      elsif p_style_text_align[1].text.include?("Plot")
        plot = extract_plot("p[style='text-align: left;']", 1)

      else
        return plot if plot.present?
      end

    elsif p_style_color.present?
      if p_style_color.first.text.include?("Plot")
        plot = extract_plot("p[style='color: #666666; text-align: left;']", "first")

      elsif p_style_color[1].text.include?("Plot")
        plot = extract_plot("p[style='color: #666666; text-align: left;']", 1)

      else
        return plot if plot.present?
      end

    elsif entry.at_css("pre").present?
      if (!entry.at_css("pre").text.strip.delete("\n").blank?)   # http://axxomovies.org/treasure-island-2012/
        plot = entry.at_css("pre").text.split(" ").join(" ")

      else
        return plot if plot.present?
      end

    else       
      if (!p_elements.first.text.strip.delete("\n").blank?)
        if p_elements.first.text.include?("Plot")
          plot = extract_plot("p", "first")

        else
          plot = p_elements.first.text.strip.delete("\n")
        end

      elsif (!p_elements[1].text.strip.delete("\n").blank?)
        if p_elements[1].text.include?("Plot")
          plot = extract_plot("p", 1)

        else
          plot = p_elements[1].text.strip.delete("\n")
        end

      elsif (!p_elements[2].text.strip.delete("\n").blank?)     # http://axxomovies.org/hugo-2011
        if p_elements[2].text.include?("Plot")
          plot = extract_plot("p", 2)

        else
          plot = p_elements[2].text.strip.delete("\n")
        end

      elsif (!p_elements[3].text.strip.delete("\n").blank?)     # http://axxomovies.org/the-philadelphia-experiment-2012-tvrip/
        if p_elements[3].text.include?("Plot")
          plot = extract_plot("p", 3)

        else
          plot = p_elements[3].text.strip.delete("\n")
        end
                                       
      elsif (!entry.css("div")[4].text.strip.delete("\n").blank?)                           
        plot = entry.css("div")[4].text.delete("\n")    # http://axxomovies.org/colombiana-2011-2/   

      else
        return plot if plot.present?       
      end      
    end

  end

  def get_source_imdb
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")

    if p_align.present?
      if p_align.last.text.include?("IMDB")
        imdb = p_align.last.at_css("a").attributes["href"].value

      else
        return imdb if imdb.present?
      end

    elsif p_style_text_align.present?
      if p_style_text_align[1].text.include?("IMDB")
        imdb = p_style_text_align[1].at_css("a").attributes["href"].value

      elsif p_style_text_align.last.text.include?("IMDB")
        imdb = p_style_text_align.last.at_css("a").attributes["href"].value

      else
        return imdb if imdb.present?
      end

    elsif p_style_color.present?
      if p_style_color[1].text.include?("IMDB")
        imdb = p_style_color[1].at_css("a").attributes["href"].value

      elsif p_style_color.last.text.include?("IMDB")
        imdb = p_style_color.last.at_css("a").attributes["href"].value

      else
        return imdb if imdb.present?
      end

    else
      return imdb if imdb.present?
    end

  end

  def get_source_size
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")

    if p_align.present?
      if p_align.last.text.include?("Size")
        size = extract_info("p[align='left']", "Size", "last")
      
      else
        return size if size.present?        
      end     

    elsif p_style_text_align.present?
      if p_style_text_align[1].text.include?("Size")
        size = extract_info("p[style='text-align: left;']", "Size", 1)

      elsif p_style_text_align.last.text.include?("Size")
        size = extract_info("p[style='text-align: left;']", "Size", "last")

      else
        return size if size.present?
      end

    elsif p_style_color.present?
      if p_style_color[1].text.include?("Size")
        size = extract_info("p[style='color: #666666; text-align: left;']", "Size", 1)

      elsif p_style_color.last.text.include?("Size")
        size = extract_info("p[style='color: #666666; text-align: left;']", "Size", "last")
      
      else
        return size if size.present?        
      end

    else
      return size if size.present?        
    end
  end

  def get_source_quality
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")

    if p_align.present?
      if p_align.last.text.include?("Quality")
        quality = extract_info("p[align='left']", "Quality", "last")
      
      else
        return quality if quality.present?
      end     

    elsif p_style_text_align.present?
      if p_style_text_align[1].text.include?("Quality")
        quality = extract_info("p[style='text-align: left;']", "Quality", 1)

      elsif p_style_text_align.last.text.include?("Quality")
        quality = extract_info("p[style='text-align: left;']", "Quality", "last")

      else
        return quality if quality.present?
      end

    elsif p_style_color.present?
      if p_style_color[1].text.include?("Quality")
        quality = extract_info("p[style='color: #666666; text-align: left;']", "Quality", 1)

      elsif p_style_color.last.text.include?("Quality")
        quality = extract_info("p[style='color: #666666; text-align: left;']", "Quality", "last")
      
      else
        return quality if quality.present?
      end

    else
      return quality if quality.present?        
    end
  end

  def get_source_language
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")

    if p_align.present?
      if p_align.last.text.include?("Language")
        language = extract_info("p[align='left']", "Language", "last")

      elsif p_align.last.text.include?("Audio")
        language = extract_info("p[align='left']", "Audio", "last")  
      
      else
        return language if language.present?
      end      

    elsif p_style_text_align.present?
      if p_style_text_align[1].text.include?("Language")
        language = extract_info("p[style='text-align: left;']", "Language", 1)

      elsif p_style_text_align[1].text.include?("Audio")
        language = extract_info("p[style='text-align: left;']", "Audio", 1)

      elsif p_style_text_align.last.text.include?("Language")
        language = extract_info("p[style='text-align: left;']", "Language", "last")

      elsif p_style_text_align.last.text.include?("Audio")
      language = extract_info("p[style='text-align: left;']", "Audio", "last")

      else
        return language if language.present?
      end

    elsif p_style_color.present?
      if p_style_color[1].text.include?("Language")
        language = extract_info("p[style='color: #666666; text-align: left;']", "Language", 1)

      elsif p_style_color[1].text.include?("Audio")
        language = extract_info("p[style='color: #666666; text-align: left;']", "Audio", 1)

      elsif p_style_color.last.text.include?("Language")
        language = extract_info("p[style='color: #666666; text-align: left;']", "Language", "last")

      elsif p_style_color.last.text.include?("Audio")
        language = extract_info("p[style='color: #666666; text-align: left;']", "Audio", "last")    
      
      else
        return language if language.present?
      end

    else
      return language if language.present?        
    end
  end

  def extract_plot(element, position)
    if position == "first"
      plot = entry.at_css(element).text.split(":")
    else
      plot = entry.css(element)[position].text.split(":")
    end
    plot.shift
    plot = plot.join.strip.delete("\n")
  end

  def extract_info(element, value_name, position)
    if position == "last"
      info = entry.css(element).last.text
    else
      info = entry.css(element)[position].text
    end
    info = info.split("\n").map { |x| x.split(":") }
    value = info.detect { |i| i.first.include?(value_name) }
    value.shift
    value = value.join.strip
  end


  def document
    @document = Nokogiri::HTML(open(self.link))
  end

  def entry
    @entry = document.css("div.entry")
  end


end
