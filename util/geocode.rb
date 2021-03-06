require 'active_support/all'
require 'colored'
require 'httparty'
require 'json'

# load and parse the JSON file of scraped crimes
results = JSON.parse(File.read("../data/all-crimes.json"))

crimes = []

# loop through each crime
results.each_with_index do |row, index|

  begin
    crime = row.to_hash

    # create the address
    address_str = "#{crime['location'].titlecase}, Durham, NC"

    # print the address to terminal
    puts "#{index}: #{address_str}".green

    # get JSON location data from the toolbox EC2 instance
    # change instance URL to your own because this one won't work anymore
    geo_info = JSON.parse(HTTParty.get("http://ec2-56-201-118-42.us-west-2.compute.amazonaws.com/maps/api/geocode/json?sensor=false&address=#{CGI::escape(address_str)}").response.body)

    crime[:geo_results] = {}
    crime[:geo_results] = geo_info['results'][0]

    crimes << crime
  rescue => e
    # if something goes wrong, break the loop and print the error
    # this could also sleep for a bit and retry
    puts "Oops: #{e}".red
    break
  end

  sleep 0.1
end

# write the results to a file
File.open("../data/all-geo.json","w") do |f|
   f.write(crimes.to_json)
end