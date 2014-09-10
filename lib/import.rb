require 'httparty'
require 'nokogiri'
require 'pat'

class Import

  def self.all
    councils = Council.where(:external => true)
    councils.each do |council|
      import(council)
    end
  end

  def self.import(council)

    doc = Nokogiri::XML HTTParty.get("http://ratings.food.gov.uk/OpenDataFiles/FHRS#{council.id}en-GB.xml").response.body
    count = 0
    internal_ids = []

    inspections(doc).each do |i|
      count += create_inspection(i)
      internal_ids << i["FHRSID"]
    end

    # Delete removed inspections
    Inspection.where('councilid = ? AND internalid not in (?)', council.id, internal_ids).destroy_all

    puts "#{count} inspection(s) added for #{council.name}!"
  end

  def self.inspections(doc)
    inspections = []
    doc.search('EstablishmentDetail').each do |i|
      inspections << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
    end
    inspections
  end

  def self.create_inspection(i)
    return 0 if i["RatingValue"] == "Exempt" || i["RatingDate"].nil?

    inspection = Inspection.find_or_create_by_internalid(i["FHRSID"])

    return 0 if i["RatingDate"].to_date == inspection.date

    latlng = latlng(i)
    address = address(i)

    inspection.update_attributes(
      internalid: i["FHRSID"],
      name:       i["BusinessName"].titleize,
      address1:   address[:line1],
      address2:   address[:line2],
      address3:   address[:line3],
      town:       address[:town],
      postcode:   address[:postcode],
      uprn:       "x",
      category:   i["BusinessType"],
      scope:      "included",
      hygiene:    99,
      structure:  99,
      confidence: 99,
      rating:     i["RatingValue"],
      date:       i["RatingDate"],
      councilid:  i["LocalAuthorityCode"],
      lat:        latlng[:lat],
      lng:        latlng[:lng],
      published:  1
    )

    inspection.tweet
    if inspection.errors.any?
      puts inspection.name
      inspection.errors.full_messages.each { |msg| puts msg }
      puts "-----"
      return 0
    else
      return 1
    end
  end

  def self.latlng(i)
    begin
      postcode = Pat.get(i["PostCode"])
      lat = postcode["geo"]["lat"]
      lng = postcode["geo"]["lng"]
    rescue
      lat = 0
      lng = 0
    end

    {
      lat: lat,
      lng: lng
    }
  end

  def self.address(i)
    address = [
                i["AddressLine1"],
                i["AddressLine2"],
                i["AddressLine3"],
                i["AddressLine4"]
              ].compact.reject { |s| s.empty? || s == "Staffordshire" }

    if address.count > 1
      town = address.pop
    else
      town = i["LocalAuthorityName"]
    end

    i["PostCode"] = "x" if i["PostCode"].blank?

    {
      line1: address[0],
      line2: address[1],
      line3: address[2],
      town: town,
      postcode: i["PostCode"] || "x"
    }
  end

end
