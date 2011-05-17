require 'helper'

class TestParameters < KNMI::TestCase
  context "find all daily" do
    setup do
      @params = KNMI::Parameters.all("daily")
    end
    
    should "by an array" do
      assert_equal @params.class, Array
    end

    should "contain KNMI::Daily object" do
     assert_equal @params[0].class, KNMI::Parameters
    end
    
    should "be length 40" do
      assert_equal @params.length, 40
    end
  end
  
  context "find all hourly" do
    setup do
      @params = KNMI::Parameters.all("hourly")
    end
    
    should "by an array" do
      assert_equal @params.class, Array
    end

    should "contain KNMI::Daily object" do
     assert_equal @params[0].class, KNMI::Parameters
    end
    
    should "be length 23" do
      assert_equal @params.length, 23
    end
  end  
  
  
  context "find a single daily parameter" do
    setup  do
      @params = KNMI::Parameters.find(period = "daily", "TX")
    end

    should "contain KNMI::Daily object" do
     assert_equal @params.class, KNMI::Parameters
    end

    should "access parameter id" do
     assert_equal @params.parameter, "TX"
    end

    should "access category id" do
     assert_equal @params.category, "TEMP"
    end

    should "access description id" do
     assert_contains @params.description, "Maximum Temperature"
    end

    should "access validation equation" do
     assert_equal @params.validate, "n.integer?"
    end

    should "access conversion equation" do
     assert_equal @params.conversion, "n / 10"
    end

    should "access units" do
     assert_equal @params.units, "C"
    end
  end
  
  context "find a mutliple daily parameter" do
    setup  do
      @params = KNMI::Parameters.find(period = "daily", ["TX", "SP"])
    end
    
    should "by an array" do
      assert_equal @params.class, Array
    end

    should "contain KNMI::Daily object" do
     assert_equal @params[0].class, KNMI::Parameters
    end
  end
  
  context "find a single hourly parameter" do
    setup  do
      @params = KNMI::Parameters.find(period = "hourly", "T")
    end

    should "contain KNMI::Daily object" do
     assert_equal @params.class, KNMI::Parameters
    end

    should "access parameter id" do
     assert_equal @params.parameter, "T"
    end

    should "access category id" do
     assert_equal @params.category, "TEMP"
    end

    should "access description id" do
     assert_equal @params.description, "Air Temperature at 1.5 m"
    end

    should "access validation equation" do
     assert_equal @params.validate, "n.integer?"
    end

    should "access conversion equation" do
     assert_equal @params.conversion, "n / 10"
    end

    should "access units" do
     assert_equal @params.units, "C"
    end
  end
  
  context "find a mutliple hourly parameter" do
    setup  do
      @params = KNMI::Parameters.find(period = "hourly", category = ["T", "T10N"])
    end
    
    should "by an array" do
      assert_equal @params.class, Array
    end

    should "contain KNMI::Daily object" do
     assert_equal @params[0].class, KNMI::Parameters
    end
  end
  
  context "find parameters from category" do
    setup do
      @params = KNMI::Parameters.category(period = "hourly", "TEMP")
    end
    
    should "contain KNMI::Daily object" do
     assert_equal @params.class, Array
    end
    
    should "be length 3" do
      assert_equal @params.length, 3
    end
  end
  
  context "find parameters from two categories" do
    setup do
      @params = KNMI::Parameters.category(period = "hourly", ["TEMP", "WIND"])
    end
    
    should "contain KNMI::Daily object" do
     assert_equal @params.class, Array
    end
    
    should "be length 7" do
      assert_equal @params.length, 7
    end
  end
  
end