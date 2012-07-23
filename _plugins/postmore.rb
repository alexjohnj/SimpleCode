# By: Jacques Fortier of http://www.jacquesf.com/
# Modified by me so that it'll also detect <!-- more --> (with the spaces)

module PostMore
  def postmorefilter(input, url, text)
    if input.include? "<!--more-->"
      input.split("<!--more-->").first + "<p class='more'><a href='#{url}'>#{text}</a></p>"
    elsif input.include? "<!-- more -->"
      input.split("<!-- more -->").first + "<p class='more'><a href='#{url}'>#{text}</a></p>"
    else
      input
    end
  end
end

Liquid::Template.register_filter(PostMore)
