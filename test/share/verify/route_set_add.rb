require "set"
s = +"abc"
st = Set.new
st << s
s << "!"
p st.include?("abc")
