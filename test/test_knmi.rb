require 'helper'

class TestKNMI < KNMI::TestCase
  context "a station by location" do 
    setup do
      @station = KNMI.station_by_location(52.165, 4.419)
    end
    
    should "be a struct" do
      assert_equal @station.class, KNMI::Station
    end
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
  end
  
  context "a station by id" do 
    setup do
      @station = KNMI.station_by_id(210)
    end
    
    should "be a struct" do
      assert_equal @station.class, KNMI::Station
    end
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
    
  end
  
  
  # Test KNMI.Parameters Daily
  context "fetch daily - a single parameter" do
    setup do
      @params = KNMI.parameters(period = "daily", "TX")
    end
    
    should "be kind of Array" do
      assert_equal @params.class, Array
    end
    
    should "contain KNMI::Parameters object" do
      assert_equal @params[0].class, KNMI::Parameters
    end
    
    should "be length 1" do
      assert_equal @params.length, 1
    end
  end
    
  context "fetch daily - more than one parameter" do
    setup do
      @params = KNMI.parameters(period = "daily", ["TX", "TG"])
    end
    
    should "be length 2" do
      assert_equal @params.length, 2
    end
  end
    
  context "fetch daily - one doubly named parameter" do
    setup do
      @params = KNMI.parameters(period = "daily", ["TX", "TX"])
    end
    
    should "be length 1" do
      assert_equal @params.length, 1
    end
  end

  context "fetch daily - a single parameter category" do
    setup do
      @params = KNMI.parameters(period = "daily", params = "", categories = "TEMP")
    end
    
    should "be length 7" do
      assert_equal @params.length, 7
    end
  end
  
  context "fetch daily - more than one parameter category" do
    setup do
      @params = KNMI.parameters(period = "daily", params = "", categories = ["TEMP", "WIND"])
    end
    
    should "be length 16" do
      assert_equal @params.length, 16
    end
  end
  
  context "fetch daily - one doubly named parameter category" do
    setup do
      @params = KNMI.parameters(period = "daily", params = "", categories = ["WIND", "WIND"])
    end
    
    should "be length 9" do
      assert_equal @params.length, 9
    end
  end
  
  context "fetch daily - a single parameter and a single parameter category of same grouping" do
    setup do
      @params = KNMI.parameters(period = "daily", params = "TX", categories = "TEMP")
    end
    
    should "be length 7" do
      assert_equal @params.length, 7
    end
  end
  
  context "fetch daily - an param or category which isn't available" do
    setup do
      @params = KNMI.parameters(period = "daily", "Tmax")
    end
    
    should "be length 0" do
      assert_equal @params.length, 0 
    end
  end
  
  context "get data over daily timestep" do
    setup do
      station = KNMI.station_by_location(52.165, 4.419)
      params = KNMI.parameters(period = "daily", "TX")
      start_at = Time.utc(2010, 6, 28)
      end_at = Time.utc(2010, 6, 29)
      @response = KNMI.get_data(station, params, start_at, end_at)
    end
    
    should "have HTTParty::Response class" do
      assert_equal @response.class, KNMI::HttpService
    end
    
    should "have query" do
      assert_equal @response.query, ["stns=210", "vars=TX", "start=20100628", "end=20100629"]
    end
    
    should "have result" do
      assert_equal @response.data, [
        {:STN=>"210", :YYYYMMDD=>"20100628", :TX=>"268"},
        {:STN=>"210", :YYYYMMDD=>"20100629", :TX=>"239"}]
    end    
  end
  
end