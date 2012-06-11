# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def pagetitle(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end
  
  def meta_description(text)
  	content_for(:meta_description) { text.to_s }
  end
  
  def meta_keywords(tags)
  	t = []
  	tags.each do |tag| 
  		t << tag.tag.strip
  	end
  	content_for(:meta_keywords) { t.join(",") }
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end
end