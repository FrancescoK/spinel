# A constant written from a String variable names that String, so a change
# through either name is seen through the other. The constant held a copy
# and s stayed "abc": refused, not compiled wrong.
s = +"abc"
X = s
X << "!"
p s
