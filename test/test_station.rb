require 'helper'

class TestKNMI < KNMI::TestCase
  context "find a station by id" do 
    setup do
      @station = KNMI::Station.find(210)
    end
    
    should "be a KNMI::Station class" do
      assert_equal @station.class, KNMI::Station
    end
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
    
    should "should return coordinates" do
      assert_equal @station.coordinates, GeoKit::LatLng.new(52.165, 4.419)
    end
    
    should "return station city name" do
      assert_equal @station.name, "Valkenburg"
    end
    
    should "return elevation" do
      assert_equal @station.elevation, -0.20
    end
    
    should "return station photo url" do 
      assert_equal @station.photo, "http://www.knmi.nl/klimatologie/metadata/210_valkenburg_big.jpg"
    end
    
    should "return station map url" do 
      assert_equal @station.map, "http://www.knmi.nl/klimatologie/metadata/stn_210.gif"
    end
    
    should "return station web url" do 
      assert_equal @station.web, "http://www.knmi.nl/klimatologie/metadata/valkenburg.html"
    end
    
    should "contain hash with list and dates of instrumentation" do
      assert_equal @station.instrumentation.class, Hash
    end
    
  end
  
  
  context "find closest to coordinates" do
    setup do
      @station = KNMI::Station.closest_to(GeoKit::LatLng.new(52.165, 4.419))
    end
    
    should "be a KNMI::Station class" do
      assert_equal @station.class, KNMI::Station
    end    
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
  end
  
  context "find closest to lat/lng" do
    setup do
      @station = KNMI::Station.closest_to(52.165, 4.419)
    end
    
    should "be a KNMI::Station class" do
      assert_equal @station.class, KNMI::Station
    end    
    
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
  end
  
  context "find closest to lat/lng passed as an array" do
    setup do
      @station = KNMI::Station.closest_to([52.165, 4.419])
    end
    
    should "be a KNMI::Station class" do
      assert_equal @station.class, KNMI::Station
    end        
    
    should 'find id 210' do
      assert_equal @station.id, 210
    end
  end

# TODO
#   test 'should throw ArgumentError if bad argument passed into #closest_to()' do
#      lambda { KNMI::Station.closest_to('hey') }.should raise_error(ArgumentError)
#   end
#
#    test 'should throw ArgumentError if more than two arguments passed into #closest_to()' do
#      lambda { KNMI::Station.closest_to(1, 2, 3) }.should raise_error(ArgumentError)
#    end
#


end