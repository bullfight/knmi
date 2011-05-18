module KNMI
  class Calculations
  
    class << self
      
      def validate( data_hash )
        params = data[0].keys
        
        data.each do |d|
          d
        end
        params.find
      
      end
  
      def convert( data_object )
      
      end
  
    private
    
    def int
      n.integer?      
    end
    
    def hour
      (1..24).include?(n)
    end
    
    def quarter_day
      (6..24).step(6)
    end
    
    
  
    end
  
  end
end