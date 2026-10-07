# Flag-only. A Struct that includes Enumerable runs its own each, over
# members the share analysis leaves to what it does not follow: its first
# still compiles and answers the member String itself. (Reading the member
# back after the change answers a copy, here as before.)
St = Struct.new(:a, :b) do
  include Enumerable
end
st = St.new(+"ab", +"cd")
x = st.first
x << "!"
p x
