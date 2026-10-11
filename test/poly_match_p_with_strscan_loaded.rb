# With StringScanner loaded, `x.match?(re)` on a value of more than one class
# may reach StringScanner#match?, which answers a length or nil, so the call
# is a value of more than one class too. It compiles, and each receiver
# answers its own.
require "strscan"

def add_tag(tag, content)
  if content.match?(/\A[\w\s]+\z/)
    "#{tag}:#{content}"
  else
    "<#{tag}>"
  end
end

def probe(x) = x.match?(/\w+/)

def from(x) = x.match?(/b/, 2)

def at(x) = x =~ /b/

INTEGER_VALUE = /\A[-+]?\d+\z/

def integer?(value) = value.match?(INTEGER_VALUE)

def from_any(x, pat) = x.match?(pat, 2)

p add_tag("b", "hello")
p add_tag("i", :"a+b")
p add_tag("i", "a+b")
p probe("abc")
p probe(:abc)
p probe(" ")
p probe(StringScanner.new("xy z"))
p probe(StringScanner.new(" z"))
begin
  probe(/re/)
rescue TypeError => e
  p e.class
end
p from("abcb")
p from(:ab)
p at("abc")
p at(:abc)
p integer?("-12")
p integer?("1x")
p integer?(StringScanner.new("42 apples"))
p from_any("abcb", /b/)
p from_any(:abcb, "b")
p from_any("ab", "b")
s = StringScanner.new("abc")
p s.match?(/\w+/)
