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