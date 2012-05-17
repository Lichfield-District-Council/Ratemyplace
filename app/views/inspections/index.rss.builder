xml.instruct!
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:georss" => "http://www.georss.org/georss" do
 xml.channel do

   xml.title       "Ratemyplace - Latest Inspections"
   xml.link        url_for :only_path => false, :controller => 'inspections'
   xml.description "The Latest Additions to Ratemyplace"

   @rssinspections.each do |inspection|
     xml.item do
       xml.title       "#{inspection.name}, #{inspection.town}"
       xml.link        url_for :only_path => false, :controller => 'inspections', :action => 'show', :id => inspection.slug
       xml.guid        url_for :only_path => false, :controller => 'inspections', :action => 'show', :id => inspection.slug
       if inspection.rating == 0
       	xml.description "<strong>No Stars</strong>"
       else
       	xml.description image_tag("http://www.ratemyplace.org.uk/assets/" + "rating#{inspection.rating}.png", :alt => "#{inspection.rating} / 5") + "<br />#{inspection.rating} / 5"
       end
       xml.georss :featurename do
       	xml.text! full_address(inspection)
       end
       xml.georss :point do
       	xml.text! inspection.lat.to_s + ' ' + inspection.lng.to_s
       end
       xml.pubDate inspection.date.strftime("%a, %d %b %Y %H:%M:%S %z")
     end
   end

 end
end