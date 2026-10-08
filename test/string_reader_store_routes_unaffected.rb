# spinel: share
# Shapes beside the String routes that are refused (a reader on a boxed
# receiver, a kept `scan` match): no in-place change is observed through
# the other name, the value is no String, or the analysis already shares
# it, so each compiles and answers as CRuby. The other routes' neighbours
# are in string_block_param_store_unaffected.rb and
# string_container_store_unaffected.rb.
T = Struct.new(:text)
t1 = [T.new(+"value"), 0][0].text; t1 << "!"; p t1
s2 = [T.new(+"value"), 0][0]
t2 = s2.text; t2 = t2 + "?"; p t2, s2.text
p s2.text.equal?(s2.text)
class C
  attr_reader :text
  def initialize(t) = (@text = t)
end
c3 = C.new(+"v"); t3 = c3.text; t3 << "!"; p c3.text

a10 = []
"a1b2".scan(/[a-z]/) { |m20| a10 << m20 }; p a10
"a1b2".scan(/[a-z]/) { |m21| m21 << "*"; p m21 }
a11 = []
"a1b2".scan(/[a-z]/) { |m23| a11 << m23.upcase }; p a11
a12 = []
"a1b2".each_char { |m25| a12 << m25; m25 << "*" }; p a12
a13 = []
"a1b2".scan(/([a-z])(\d)/) { |m27, n27| a13 << m27; a13 << 1 }; p a13
# a reader's String changed on a boxed receiver whose members are not read again
class K14; def initialize(t) = (@text = t); attr_reader :text; end
o14 = [K14.new(+"t"), 0][0]; t14 = o14.text; t14 << "x"; p t14; p o14.class, o14.nil?
# a String reader of a class with no instance is no boxed receiver's
class Text15; attr_reader :value; def initialize = (@value = +"x"); end
class Values15; attr_reader :value; def initialize = (@value = [1]); end
o15 = [Values15.new, 0][0]; x15 = o15.value; x15 << 2; p o15.value
