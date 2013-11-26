require 'json'
require 'nokogiri'
require 'open-uri'
require 'colored'
require 'active_support/all'

# add in the url for the page we to scrape
PAGE_URL = "http://gisweb.durhamnc.gov/gis_apps/crimedata/dsp_tables.cfm?CFID=482922&CFTOKEN=13687690"

# grab the page for Nokogiri
page = Nokogiri::HTML(open(PAGE_URL))

# initialize an array to store the scraped data
crimes_arr = []

# grab the HTML rows that contain the crime data
crimes = page.css('tr.tdtxt')

# print to Terminal the number of crimes we are parsing
puts "There are currently #{crimes.size} listed".green

# loop through the crimes
crimes.each do |crime|

  # create an object to store the crime data
  crime_obj = {
    :id => crime.css('td:nth-child(1)').text.strip!, # id the Police department is using
    :date => crime.css('td:nth-child(2)').text.strip!, # the date the crime occured
    :location => crime.css('td:nth-child(3)').text.strip!, # the address of the crime
    :general_type_crime => crime.css('td:nth-child(4)').text.strip!, # the general type of crime
    :specific_type_crime => crime.css('td:nth-child(5)').text.strip!, # more specific type of crime
    :incident_number => crime.css('td:nth-child(6)').text.strip! # more specific type of crime
  }

  # print the crime to Terminal
  puts "#{crime_obj[:date]}: #{crime_obj[:general_type_crime]} at #{crime_obj[:location]}"

  # store the crime
  crimes_arr << crime_obj

end


# write the crime data as JSON to a file
File.open("../data/all-crimes-2013.json","w") do |f|
  f.write(crimes_arr.to_json)
end