require 'net/http'
require 'json'
require 'fileutils'

# This is the primary input. You can find this when looking at the allscans page in the archives. eg. for the url https://archief.amsterdam/inventarissen/scans/334/5.1.1.22 the item path is 5.1.1.22
item_path = "5.1.1.22"

base_url = "https://webservices8.picturae.pro/archives/findingaid/334"
api_key = "eb37e65a-eb47-11e9-b95c-60f81db16c0e"
lang = "nl_NL"

url = "#{base_url}?apiKey=#{api_key}&lang=#{lang}&itemPath=#{item_path}"

response = Net::HTTP.get_response(URI(url))
data = JSON.parse(response.body)

levels = item_path.split('.').length
split = item_path.split('.')

thumbnail_urls = []  # Initialize an empty list to store thumbnail URLs

if levels == 2
  puts 'level 2'
  level1 = split[0].to_i - 1
  data['findingAid']['tree'][level1]['children'].each do |item|
    if item['cpath'] == item_path
      item['scans'].each { |x| thumbnail_urls << x['thumbnailUrl'] }
    end
  end
elsif levels == 3
  puts 'level 3'
  level1 = split[0].to_i - 1
  level2 = split[1].to_i - 1
  data['findingAid']['tree'][level1]['children'][level2]['children'].each do |item|
    if item['cpath'] == item_path
      item['scans'].each { |x| thumbnail_urls << x['thumbnailUrl'] }
    end
  end
elsif levels == 4
  puts 'level 4'
  level1 = split[0].to_i - 1
  level2 = split[1].to_i - 1
  level3 = split[2].to_i - 1
  data['findingAid']['tree'][level1]['children'][level2]['children'][level3]['children'].each do |item|
    if item['cpath'] == item_path
      item['scans'].each { |x| thumbnail_urls << x['thumbnailUrl'] }
    end
  end
elsif levels == 5
  puts 'level 5'
  level1 = split[0].to_i - 1
  level2 = split[1].to_i - 1
  level3 = split[2].to_i - 1
  level4 = split[3].to_i - 1
  data['findingAid']['tree'][level1]['children'][level2]['children'][level3]['children'][level4]['children'].each do |item|
    if item['cpath'] == item_path
      item['scans'].each { |x| thumbnail_urls << x['thumbnailUrl'] }
    end
  end
else
  puts 'error in code or item path'
end

modified_strings = []
thumbnail_urls.each do |thumb|
  # Using a loop
  modified_strings << thumb.gsub('full/300,', 'full/max')
end
puts modified_strings

# Specify the folder where you want to save the files
download_folder = item_path

# Create the folder if it doesn't exist
FileUtils.mkdir_p(download_folder)

# Download each URL
modified_strings.each_with_index do |url, index|
  response = Net::HTTP.get_response(URI(url))

  if response.code.to_i == 200
    # Extract the filename from the URL and add a counter to make it unique
    filename = File.join(download_folder, "#{index + 1}_#{File.basename(url)}")

    # Save the content to a file
    File.write(filename, response.body)
    puts "Downloaded: #{url}"
  else
    puts "Failed to download: #{url}"
  end
end
