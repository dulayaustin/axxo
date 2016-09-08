require 'nokogiri'
require 'open-uri'


class Movie < ActiveRecord::Base
  has_many :movie_categories
  has_many :categories, through: :movie_categories, source: :category


  scope :pending, -> {where(status: "pending")}
  scope :valid, -> {where(status: "passed")}
  scope :recent, -> {order('id DESC')}
  scope :without_plot, -> {where(plot: nil)}
  scope :without_info, -> {where(size: nil)}


  def get_specific_details!
    return if torrent.present?
    self.image = get_source_image
    self.torrent = get_source_torrent
    self.youtube_url = get_source_youtube_url
    self.status = "passed"

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
    
  end

  def get_source_plot
    return plot if plot.present?
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.present?        
      if p_align.first.text.include?("Plot")
        plot = extract_plot("p[align='left']", "first")

      elsif p_align[1].present? && p_align[1].text.include?("Plot")
        plot = extract_plot("p[align='left']", 1)

      else
        return plot
      end

    elsif p_style_text_align.present?
      if p_style_text_align.first.text.include?("Plot")
        plot = extract_plot("p[style='text-align: left;']", "first")

      elsif (!p_style_text_align.first.text.strip.delete("\n").blank?) && (!p_style_text_align.first.text.include?("Genre")) # http://axxomovies.org/tom-and-jerry-the-lost-dragon-2014/
        plot = p_style_text_align.first.text.strip.delete("\n") # http://axxomovies.org/retreat-2011/ && http://axxomovies.org/jack-irish-bad-debts-2012-10/

      elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("Plot")
        plot = extract_plot("p[style='text-align: left;']", 1)

      elsif p_style_text_align[2].present? && p_style_text_align[2].text.include?("Plot")
        plot = extract_plot("p[style='text-align: left;']", 2)    # http://axxomovies.org/elfie-hopfkins-dvdrip/

      elsif p_style_color.first.present? && p_style_color.first.text.include?("Plot")
        plot = extract_plot("p[style='color: #666666; text-align: left;']", "first")  # http://axxomovies.org/wakolda-2013/

      elsif entry.at_css("p.plotSummary").present? && entry.at_css("p.plotSummary").text.include?("Plot")  # http://axxomovies.org/girltrash-all-night-long-2014/
        plot = extract_plot("p.plotSummary", "first")

      else
        return plot
      end

    elsif p_style_color.present?
      if p_style_color.first.present? && p_style_color.first.text.include?("Plot")
        plot = extract_plot("p[style='color: #666666; text-align: left;']", "first")

      elsif p_style_color[1].present? && p_style_color[1].text.include?("Plot")
        plot = extract_plot("p[style='color: #666666; text-align: left;']", 1)

      else
        return plot
      end

    elsif entry.at_css("pre").present?
      if (!entry.at_css("pre").text.strip.delete("\n").blank?)   # http://axxomovies.org/treasure-island-2012/
        plot = entry.at_css("pre").text.split(" ").join(" ")

      else
        return plot
      end

    else       
      if (!p_elements.first.text.strip.delete("\n").blank?) # http://axxomovies.org/playback-2012/ ISSUE: result TRUE even it is blank, must be at p[1] element
        if p_elements.first.text.include?("Plot")
          plot = extract_plot("p", "first")

        elsif (!p_elements.first.text.include?("Release"))
          plot = p_elements.first.text.strip.delete("\n")
        end

      elsif p_elements[1].present? && (!p_elements[1].text.strip.delete("\n").blank?) && (!p_elements[1].text.include?("Tags"))
        if p_elements[1].text.include?("Plot")
          plot = extract_plot("p", 1)

        elsif (!p_elements[1].text.include?("Release"))
          plot = p_elements[1].text.strip.delete("\n")
        end

      elsif p_elements[2].present? && (!p_elements[2].text.strip.delete("\n").blank?) && (!p_elements[2].text.include?("Tags"))     # http://axxomovies.org/hugo-2011
        if p_elements[2].text.include?("Plot")
          plot = extract_plot("p", 2)

        elsif (!p_elements[2].text.include?("Release"))
          plot = p_elements[2].text.strip.delete("\n")
        end

      elsif p_elements[3].present? && (!p_elements[3].text.strip.delete("\n").blank?) && (!p_elements[3].text.include?("Tags"))     # http://axxomovies.org/white-rabbit-2013/ 
        if p_elements[3].text.include?("Plot")
          plot = extract_plot("p", 3)

        elsif (!p_elements[3].text.include?("Release"))
          plot = p_elements[3].text.strip.delete("\n")
        end

      elsif p_elements[4].present? && (!p_elements[4].text.strip.delete("\n").blank?) && (!p_elements[4].text.include?("Tags"))    # http://axxomovies.org/any-questions-for-ben-2012/
        if p_elements[4].text.include?("Plot")
          plot = extract_plot("p", 4)

        elsif (!p_elements[4].text.include?("Release"))
          plot = p_elements[4].text.strip.delete("\n")
        end

      elsif p_elements[5].present? && (!p_elements[5].text.strip.delete("\n").blank?) && (!p_elements[5].text.include?("Tags"))    # http://axxomovies.org/men-in-black-3-2012/
        if p_elements[5].text.include?("Plot")
          plot = extract_plot("p", 5)

        elsif (!p_elements[5].text.include?("Release"))
          plot = p_elements[5].text.strip.delete("\n")
        end
                                       
      elsif (!entry.css("div")[5].text.strip.delete("\n").blank?)                           
        plot = entry.css("div")[5].text.delete("\n")    # http://axxomovies.org/colombiana-2011-2/   

      else
        return plot     
      end      
    end

  end

  def get_source_imdb
    return imdb if imdb.present?
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.last.present? && p_align.last.text.include?("IMDB")
      imdb = p_align.last.at_css("a").attributes["href"].value

    elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("IMDB")
      imdb = p_style_text_align[1].at_css("a").attributes["href"].value

    elsif p_style_text_align.last.present? && p_style_text_align.last.text.include?("IMDB")
      imdb = p_style_text_align.last.at_css("a").attributes["href"].value

    elsif p_style_color.last.present? && p_style_color.last.text.include?("IMDB")
      imdb = p_style_color.last.at_css("a").attributes["href"].value

    elsif p_elements[3].present? && p_elements[3].text.include?("IMDB") # http://axxomovies.org/away-and-back-2015/
      imdb = p_elements[3].css("a").last.attributes["href"].value

    elsif p_elements[4].present? && p_elements[4].text.include?("IMDB") # http://axxomovies.org/the-philadelphia-experiment-2012-tvrip/
      imdb = p_elements[4].css("a").last.attributes["href"].value

    else
      return imdb
    end

  end

  def get_source_size
    return size if size.present?
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.last.present? && p_align.last.text.include?("Size")
      size = extract_info("p[align='left']", "Size", "last")
   
    elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("Size")
      size = extract_info("p[style='text-align: left;']", "Size", 1)

    elsif p_style_text_align.last.present? && p_style_text_align.last.text.include?("Size")
      size = extract_info("p[style='text-align: left;']", "Size", "last")

    elsif p_style_color.last.present? && p_style_color.last.text.include?("Size") # http://axxomovies.org/warrior-princess-2014/
      size = extract_info("p[style='color: #666666; text-align: left;']", "Size", "last")

    elsif p_elements[3].present? && p_elements[3].text.include?("Size")
      size = extract_info("p", "Size", 3)

    elsif p_elements[4].present? && p_elements[4].text.include?("Size") 
      size = extract_info("p", "Size", 4)

    else
      return size
    end

  end

  def get_source_quality
    return quality if quality.present?
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.last.present? && p_align.last.text.include?("Quality")
      quality = extract_info("p[align='left']", "Quality", "last")
 
    elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("Quality")
      quality = extract_info("p[style='text-align: left;']", "Quality", 1)

    elsif p_style_text_align.last.present? && p_style_text_align.last.text.include?("Quality")
      quality = extract_info("p[style='text-align: left;']", "Quality", "last")

    elsif p_style_color.last.present? && p_style_color.last.text.include?("Quality")
      quality = extract_info("p[style='color: #666666; text-align: left;']", "Quality", "last")

    elsif p_elements[3].present? && p_elements[3].text.include?("Quality")
      quality = extract_info("p", "Quality", 3)

    elsif p_elements[4].present? && p_elements[4].text.include?("Quality") 
      quality = extract_info("p", "Quality", 4)

    else
      return quality
    end

  end

  def get_source_language
    return language if language.present?
    p_align = entry.css("p[align='left']")
    p_style_text_align = entry.css("p[style='text-align: left;']")
    p_style_color = entry.css("p[style='color: #666666; text-align: left;']")
    p_elements = entry.css("p")

    if p_align.last.present? && p_align.last.text.include?("Language")
      language = extract_info("p[align='left']", "Language", "last")

    elsif p_align.last.present? && p_align.last.text.include?("Audio")
      language = extract_info("p[align='left']", "Audio", "last")  
      
    elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("Language")
      language = extract_info("p[style='text-align: left;']", "Language", 1)

    elsif p_style_text_align[1].present? && p_style_text_align[1].text.include?("Audio")
      language = extract_info("p[style='text-align: left;']", "Audio", 1)

    elsif p_style_text_align.last.present? && p_style_text_align.last.text.include?("Language")
      language = extract_info("p[style='text-align: left;']", "Language", "last")

    elsif p_style_text_align.last.present? && p_style_text_align.last.text.include?("Audio")
      language = extract_info("p[style='text-align: left;']", "Audio", "last")

    elsif p_style_color.last.present? && p_style_color.last.text.include?("Language")
      language = extract_info("p[style='color: #666666; text-align: left;']", "Language", "last")

    elsif p_style_color.last.present? && p_style_color.last.text.include?("Audio")
      language = extract_info("p[style='color: #666666; text-align: left;']", "Audio", "last")

    elsif p_elements[3].present? && p_elements[3].text.include?("Language")
      language = extract_info("p", "Language", 3)

    elsif p_elements[4].present? && p_elements[4].text.include?("Language") 
      language = extract_info("p", "Language", 4)

    else
      return language
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

  def trim_link
    if entry.at_css("h1").present? && entry.at_css("h1").text.include?("Sorry")
      url = self.link.split("-")     
      url.pop
      url = url.join("-")

      self.link = url
    end
  end

  def valid_url?    
    if self.link.blank?
      self.status = "failed"
    end
  end


end
