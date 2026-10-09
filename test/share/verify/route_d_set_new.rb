require "set"; s = +"v"; t = s; t << "!"; st = Set.new([s]); t << "?"; p st.include?("v!"), st.to_a
