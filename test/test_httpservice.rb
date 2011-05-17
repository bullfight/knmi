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
      assert_equal @response.class, HTTParty::Response
    end
    
    should "have query" do
      assert_equal @response.query, HTTParty::Response
    end
    
    should "have result" do
      assert_equal @response.result, HTTParty::Response
    end
    
  end
  
  context "get hourly data from station" do
    setup do
      station = KNMI.station_by_id(235)
      parameter = KNMI.parameter("daily", "TX")
      start_at = Time.utc(2010, 4, 27)
      end_at = Time.utc(2010, 4, 28)
      
      @response = KNMI::HttpService.get_daily(station, parameter, start_at, end_at)
    end
  end

end