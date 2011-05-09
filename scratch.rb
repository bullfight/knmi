# info
# http://www.knmi.nl/klimatologie/uurgegevens/scriptxs-nl.html#uur
# Daily Data
# http://www.knmi.nl/climatology/daily_data/getdata_day.cgi 
# http://www.knmi.nl/klimatologie/daggegevens/getdata_dag.cgi 

# Hourly Data
# http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi?stns=235 

# Precip Data
#http://www.knmi.nl/klimatologie/uurgegevens/getdata_uur.cgi 
# http://www.knmi.nl/climatology/rainfall_data/getdata_rr.cgi

# YAML maker
require 'YAML'
require 'CSV'

csv_data = CSV.read "./data/knmi_daily_data_key.csv"
headers = csv_data.shift.map {|i| i.to_s }
string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

yml = array_of_hashes.to_yaml
File.open("./data/knmi_daily_data_key.yml", 'w') {|f| f.write(yml) }

# YAML maker
require 'YAML'
require 'CSV'

csv_data = CSV.read "./data/knmi_hourly_data_key.csv"
headers = csv_data.shift.map {|i| i.to_s }
string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

yml = array_of_hashes.to_yaml
File.open("./data/knmi_hourly_data_key.yml", 'w') {|f| f.write(yml) }


# KNMI Station MetaData ################################################
require 'open-uri'
require 'nokogiri'

current_stations = [210,225,235,240,242,249,251,257,260,265,267,269,
  270,273,275,277,278,279,280,283,286,290,310,319,323,330,340,
  344,348,350,356,370,375,377,380,391]
  



res = KNMI.new(235, "TX")
x= res.parse

stations = res[:stations]
stations.each do |station|
  station.merge!({
    :photo => 'http://www.knmi.nl/klimatologie/metadata/' + station[:station_code] + '_' + station[:name].downcase + '_big.jpg',
    :map => 'http://www.knmi.nl/klimatologie/metadata/stn_' + station[:name] + '.gif',
    :web => 'http://www.knmi.nl/klimatologie/metadata/valkenburg' + station[:name].downcase + '.html'
  })
end


doc = Nokogiri::HTML(open('http://www.knmi.nl/klimatologie/metadata/' + station.downcase + '.html'))

rows = doc.css('table.onelinetable')

x = [] 
rows.search('table').each do |row|
  properties = row.search('text()').collect {|text| text.to_s}
  x << properties
end

d = x.flatten.map { |x| x.strip }.delete_if { |x| x.empty? }

ind = []
['Temperatuurmetingen', 'Neerslagmetingen', 
  'Luchtdrukmetingen', 'Windmetingen'].each { |e| ind << d.index { |x| x[/#{e}/]}}
ind << d.index(d[-1])

data = {}
["temperature", "precipitation", "pressure", "wind"].each_with_index do |m, index|
  dat = d[(ind[index] + 2)..(ind[index + 1] - 1)]
  epoch = dat.values_at( * dat.each_index.select { |i| i.even?} )
  epoch.map! { |e| e.split(" - ") } 
  instrument = dat.values_at( * dat.each_index.select { |i| i.odd?} )
  
  ts = []
  epoch.each_with_index do |e, index|
    ts << {
      :epoch => index,
      :start => e[0],
      :end => e[1],
      :instrument => instrument[index]
    }
  end
  
  data.merge!({m.intern => ts})
end




x = {
  :epoch => "Present", 
  :start => epoch.last[0], 
  :end => "Present", 
  :instrument => instrument.last
}





station_ind = d.index { |x| x[/Valkenburg/] }
temp_ind = d.index("Temperatuurmetingen:")
precip_ind = d.index("Neerslagmetingen:")
press_ind = d.index("Luchtdrukmetingen:")
wind_ind = d.index("Windmetingen:")

station = d[(station_ind + 1)..(temp_ind - 1)]
temp = d[(temp_ind + 2)..(precip_ind - 1)]
precip = d[(precip_ind + 2)..(press_ind - 1)]
press = d[(press_ind + 2)..(wind_ind - 1)]
wind = d[(wind_ind + 2)..(d.length)]


epoch = temp.values_at( * temp.each_index.select { |i| i.even?} )
epoch.map! { |e| e.split(" - ") } 
instrument = temp.values_at( * temp.each_index.select { |i| i.odd?} )

x = {
  :epoch => "Present", 
  :start => epoch.last[0], 
  :end => "Present", 
  :instrument => instrument.last
  }

ind = (0..temp.index(temp.last)).step(2)
temp[ind]
temp[0..-1].step(2)














# Backup
x = stations.to_yaml
File.open("./data/current_stations.txt", 'w') {|f| f.write(x) }















  
x = []
stations.each do |station|
  if station[:name].nil? == false
    x << station
  end
end

x = []
stations.each_with_index do |station|
  x << station[:name]
end


stations.each do |s|
  code << s[:station_code]
  lat << s[:lat]
  lng << s[:lng]
  elev << s[:elev]
  name << s[:name]
end



# Get all Stations
res = KNMI.get_station([(1..600).to_a], "TX")

stations = res[:stations]

# Get Index of valid stations
x = {}
["station_code", "lat", "lng", "elev", "name" ].each do |e|
  x.merge!({e.intern => []})

  stations.each_with_index do |station, index|
    if station[e.intern].blank? == false
      x[e.intern] << index
    end
  end
end

x[:lat] == x[:lng]
x[:lat] == x[:name]
x[:name] == x[:elev]

index = x[:name]


stats = []
index.each do |i|
  stats << stations[i]
end
  
File.open("valid_stations", 'w') {|f| f.write(stats) }

