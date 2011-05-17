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
      assert_equal @response.data, [{:STN=>"235", :YYYYMMDD=>"20100628", :TX=>"263"}, {:STN=>"235", :YYYYMMDD=>"20100629", :TX=>"225"}]
    end    
  end
  
  context "get hourly data from station" do
    setup do
      station = KNMI.station_by_id(235)
      parameter = KNMI.parameters("hourly", "T")
      start_at = Time.utc(2010, 4, 27, 0)
      end_at = Time.utc(2010, 4, 27, 2)
      
      @response = KNMI::HttpService.get_hourly(station, parameter, start_at, end_at)
    end
    
    should "have HTTParty::Response class" do
      assert_equal @response.class, KNMI::HttpService
    end
    
    should "have query" do
      assert_equal @response.query, ["stns=235", "vars=T", "start=2010042701", "end=2010042703"]
    end
    
    should "have result" do
      assert_equal @response.data, [
        {:STN=>"235", :YYYYMMDD=>"20100427", :HH=>"1", :T=>"88"},
        {:STN=>"235", :YYYYMMDD=>"20100427", :HH=>"2", :T=>"79"},
        {:STN=>"235", :YYYYMMDD=>"20100427", :HH=>"3", :T=>"73"} ]
    end
  end

end