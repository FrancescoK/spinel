# String#succ carries alphanumerics only; scan with (named) capture groups
# returns capture rows (value, block, and destructured block forms);
# slice!(regexp); $~ is a first-class MatchData built from the registers.
p("<<koala>>".succ)
p("az".succ)
p("zz".succ)
p("a9".succ)
p("Zz".succ)
p("zz9".succ)
p("1.9".succ)
p("-9".succ)
p("abc".succ)
p("THX1138".succ)
p("***".succ)
p("1999".succ)
p("a1b2".scan(/(?<d>\d)/))
p("a1b2".scan(/\d/))
p("a1b2".scan(/([a-z])(\d)/))
"a1b2".scan(/(?<d>\d)/) { |m| p m }
"a1b2".scan(/([a-z])(\d)/) { |x, y| p [x, y] }
s = +"hello"
p(s.slice!(/l+/))
p(s)
t = +"hello"
p(t.slice!(/z+/))
p(t)
"hello" =~ /l(l)/
p($~.class)
p($~.is_a?(MatchData))
p($~[0])
p($~[1])
p($~.pre_match)
p($~.post_match)
"zzz" =~ /q/
p($~)
