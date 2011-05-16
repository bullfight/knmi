module KNMI
  # Delete Invalid Variables and keep those valid, if none are valid replace with all
  def check_variables(vars)

    if vars.kind_of?(Array) == false 
      vars = [vars]
    end

    # Collections of variables and all Possible Variables
    varOpts = {
      "WIND" => ["DDVEC", "FG", "FHX", "FHX", "FXX"], 
      "TEMP" => ["TG", "TN", "TX", "T10N"], 
      "SUNR" => ["SQ", "SP", "Q"],
      "PRCP" => ["DR", "RH", "EV24"],
      "PRES" => ["PG", "PGX", "PGN"],
      "VICL" => ["VVN", "VVX", "NG"],
      "MSTR" => ["VVN", "VVX", "NG"],
      "ALL"  => ["DDVEC", "FHVEC", "FG", "FHX", 
                 "FHXH", "FHN", "FHNH", "FXX", "FXXH", "TG", "TN", 
                 "TNH", "TX", "TXH", "T10N", "T10NH", "SQ", "SP", 
                 "Q", "DR", "RH", "RHX", "RHXH", "EV24", "PG", "PX", 
                 "PXH", "PN", "PNH", "VVN", "VVNH", "VVX", "VVXH", 
                 "NG", "UG", "UX", "UXH", "UN", "UNH"]
    }

      # Drop in invalid vars
     vars = ( vars & varOpts.to_a.flatten )

     # Only Allow Variable to be selected once, All, or TEMP, not ALL & TEMP
     # And count the number of selected variables
  	if vars.include?("ALL") == true or vars.empty? == true
      vars = "ALL"
      nvars = varOpts["ALL"].count
  	elsif (vars & varOpts.keys) # check if contains keys

      x = []
      (vars & varOpts.keys).each do |k|
        x << varOpts.values_at(k)
      end
      vars = (vars - x.flatten)

      nvars = 0
      ( vars & varOpts.keys ).each do |v|
        nvars += varOpts[v].count
      end

      ( vars - varOpts.keys ).each do |v|
        nvars += 1
      end      
  	end

    return vars, nvars
  end
end