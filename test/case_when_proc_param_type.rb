# `case v when pr` is `pr === v`: a Proc condition's parameter takes the case
# subject's type. It kept the Integer default, so a lambda reading a String
# raised NoMethodError for Integer.
long = ->(s) { s.length > 4 }
case "seven"
when long then p :long
else p :short
end

up = proc { |s| s.upcase == "AB" }
case "ab"
when up then p :upper
else p :other
end

def classify(word)
  short = ->(w) { w.size < 3 }
  case word
  when short then :short
  else :long
  end
end
p classify("hi")
p classify("hello")

half = ->(x) { x > 2.5 }
case 3.5
when half then p :big
end

case 7
when ->(n) { n.even? } then p :even
when ->(n) { n.odd? } then p :odd
end
