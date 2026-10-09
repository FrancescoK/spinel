# spinel: not-cruby -- two different signatures for one method are refused
# A method annotated differently in two openings of its class.
class K
  #: (Integer) -> Integer
  def m(x) = x
end

class K
  #: (String) -> String
  def m(x) = x
end

p K.new.m("s")
