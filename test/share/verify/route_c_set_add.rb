s = +"abc"
t = s
require "set"; st = Set.new; st << s; s << "!"; p st.include?("abc")
p s
p t
