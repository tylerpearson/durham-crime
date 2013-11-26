require 'json'
require 'colored'

# read and parse the JSON data
results = JSON.parse(File.read("../data/all-geo.json"))

# initialize the GeoJSON
geo_json = {
    :type => "FeatureCollection",
    :features => []
  }

# loop through the crimes
results.each_with_index do |crime, index|

  # print crime info to Terminal as we loop
  puts "#{crime['location']}".green

  # save crime data as GeoJSON
  the_crime = {
    :type => "Feature",
    :id => crime['incident_number'],
    :geometry => {
      :type => "Point",
      :coordinates => [crime['geo_results']['geometry']['location']['lng'], crime['geo_results']['geometry']['location']['lat']]
    },
    :properties => {
        :title => crime['general_type_crime'],
        :specific_type => crime['specific_type_crime'],
        :address => crime['location'],
        :date => crime['date'],
        :incident_id => crime['incident_number']
    }
  }

  # customize the markers some
  marker_properties = {
      :'marker-color' => '#e5ec2b', # yellow
      :'marker-size' => "small" # select a marker size
    }

  # highlight rapes and homicides
  if crime['general_type_crime'].downcase == "forcible rape" || crime['general_type_crime'].downcase == "homicide offenses"
    marker_properties[:'marker-color'] = '#cb1414'
  end

  # merge the marker info
  the_crime[:properties].merge!(marker_properties)

  geo_json[:features] << the_crime
end

# write the GeoJSON data to a file
File.open("../data/all-crimes.geojson","w") do |f|
  f.write(geo_json.to_json)
end