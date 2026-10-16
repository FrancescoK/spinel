# String#match(re) { |m| ... } yields the MatchData to a block whose
# value is built from it: an Array or a String holding m. The block's last
# expression was built before the match ran, so it held m's nil.

def wrap(s) = s.match(/(c)/) { |m| [:y, m] }
p wrap("xcx")
p wrap("xyz")

x = "acb".match(/c(b)/) { |m| [m[1], m.pre_match] }
p x

n = 0
r = "key=val".match(/(\w+)=(\w+)/) do |m|
  n += 1
  "#{m[2]}/#{m[1]}"
end
p r
p n

def body(s)
  s.match(/(\d+)/) do |m|
    v = m[1].to_i
    [v, v * 2]
  end
end
p body("a12")

# the Regexp receiver's block form: a literal, and one held in a local
p(/(c)/.match("xcx") { |m| [:lit, m[1]] })
re = Regexp.new("(d)")
p(re.match("xdx") { |m| [:var, m[1], m.post_match] })
p(re.match("xyz") { |m| [:var, m] })
