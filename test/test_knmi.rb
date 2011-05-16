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
end