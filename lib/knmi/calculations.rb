module KNMI
  class Calculations
    class << self
   
      def convert(array)
        array.each do |a|
          
          a.each_pair { |key,value| a[key] = converts(key, value) }
        
        end              
      end
          
      private
      
      def converts( key, n )
        if [:FHVEC, :FG, :FHX, :FHN, :FXX, :TG, :TN, :TX, :T10N, :Q, :RH, :EV24, :PG, :PX, :PN].include?(key)

            return n.integer? ? n / 10 : nil

        elsif [:FHXH, :FHNH, :FXXH, :TNH, :TXH, :RHXH, :PXH, :PNH, :VVNH, :VVXH, :UXH, :UNH].include?(key)

          (1..24).include?(n) ? n : nil

        elsif [:SP, :UG, :UX, :UN].include?(key)

          (0..100).include?(n) ? n : nil

        elsif [:RHX].include?(key)

          n = n.integer? ? n : nil
          return n == -1 ? 0.05 : n / 10

        elsif [:DR].include?(key)

          (0..6).include?(n) ? (n / 10) * 60 : nil

        elsif [:DDVEC].include?(key)

          (0..360).include?(n) ? n : nil

        elsif [:SQ].include?(key)

          n = (-1..6).include?(n) ? n : nil
          return n == -1 ? 0.05 : (n / 10) * 60

        elsif [:T10NH].include?(key)

          (6..24).step(6).include?(n) ? n : nil

        elsif [:NG].include?(key)

          (0..9).include?(n) ? n : nil

        elsif [:YYYYMMDD].include?(key)

          return Time.utc(
            year = n.to_s[(0..3)],
            month = n.to_s[(4..5)],
            day = n.to_s[(6..7)]
          )

        elsif [:VVN, :VVX].include?(key)

          if n == 0 
            '< 100 meters'
          elsif (1..49).include?(n)
            (n * 100).to_s + '-' + ((n+1) * 100).to_s + ' meters'
          elsif n == 50
            '5-6 kilometers'
          elsif (56..79).include?(n)
            (n - 50).to_s + '-' + (n - 49).to_s + ' kilometers'
          elsif (80..88).include?(n)
            (n - 50).to_s + '-' + (n - 45).to_s + ' kilometers'
          elsif n == 89
            '> 70 kilometers'
          end

        end
      end
      
      
    end
  end
end