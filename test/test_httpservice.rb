require 'helper'

class TestHttpService < KNMI::TestCase
  context "get daily data from station" do
    setup do
      station = KNMI.station_by_id(235)
      parameter = KNMI.parameters("daily", "TX")
      start_at = Time.utc(2010, 6, 28)
      end_at = Time.utc(2010, 6, 29)
      
      @response = KNMI::HttpService.get_daily(station, parameter, start_at, end_at)
    end
    
    should "have HTTParty::Response class" do
      assert_equal @response.class, KNMI::HttpService
    end
    
    should "have query" do
      assert_equal @response.query, ["stns=235", "vars=TX", "start=20100628", "end=20100629"]
    end
    
    should "have result" do
      assert_equal @response.result, nil
    end    
  end
  
  context "get hourly data from station" do
    setup do
      station = KNMI.station_by_id(235)
      parameter = KNMI.parameter("hourly", "T")
      start_at = Time.utc(2010, 4, 27)
      end_at = Time.utc(2010, 4, 28)
      
      @response = KNMI::HttpService.get_hourly(station, parameter, start_at, end_at)
    end
    
    should "have HTTParty::Response class" do
      assert_equal @response.class, KNMI::HttpService
    end
    
    should "have query" do
      assert_equal @response.query, ["stns=235", "vars=T", "start=2010062800", "end=2010062900"]
    end
    
    should "have result" do
      assert_equal @response.result, '# THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED:\r\n# ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE\r\n# \r\n# \r\n# STN             LON           LAT         ALT  NAME\r\n# 235:  \t4.785\t     52.924\t   0.50  DE KOOY\r\n# \r\n# YYYYMMDD = Date (YYYY=year MM=month DD=day); \r\n# TX       = Maximum temperature (in 0.1 degrees Celsius); \r\n# \r\n# STN,YYYYMMDD,   TX\r\n# \r\n  235,20100628,  263\r\n  235,20100629,  225\r\n'
    end
  end

end