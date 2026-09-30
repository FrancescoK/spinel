# `!~` runs the match `=~` runs: it sets $~ on a hit and clears it on a miss.
"abc" =~ /(b)/
p("abc" !~ /z/)
p $~, $1, $&, Regexp.last_match

"abc" =~ /z/
p("xyz" !~ /(y)/)
p $~, $1, $&, $`, $', Regexp.last_match

s = "hello"
s =~ /l/
p(s !~ /q/, $~)

r = /(c)/
"abc" =~ /(b)/
p("abc" !~ r, $~, $1)
"abc" =~ /(b)/
p(r !~ "xyz", $~)

"abc" =~ /(b)/
p(/(c)/ !~ "abc", $~, $1)
"abc" =~ /(b)/
p(/z/ !~ "abc", $~)

x = [1, "abc"][1]
"abc" =~ /(b)/
p(x !~ /z/, $~)
p(x !~ /(a)/, $~, $1)

"abc" =~ /(b)/
if "abc" !~ /z/ then p $~ end
unless "abc" !~ /c/ then p $~ end

def miss(s)
  s =~ /a/
  s !~ /z/
  $~
end

def hit(s)
  s !~ /(b)/
  [$~, $1]
end

"abc" =~ /(c)/
p miss("abc")
p hit("abc")
p $~, $1
