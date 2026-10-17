# The groups a match answers with, over subjects long enough that the
# searches hold many threads, or many backtracking entries, for many
# positions: what each thread captured stays its own however the state that
# holds it is laid out.

# leftmost-first among threads that started at the same position
p "abcd".match(/(a|ab)(c|bcd)(d*)/).to_a
p "abcd".match(/(ab|a)(c|bcd)(d*)/).to_a
p "xyz".match(/(x)(y)?(q)?(z)/).to_a

# a repetition's groups hold its last iteration, on a long run of them
s = ("ab" * 150) + "c"
m = s.match(/((a)|(b))+c/)
p m.begin(0), m[1], m[2], m[3]
m = s.match(/(?:(a)(b))*(c)/)
p m.begin(0), m.captures
p s.match(/(a|ab|b)*?(bc)/).captures

# many threads alive at once, each with its own captures
t = ("a" * 120) + "b"
p t.match(/(a|aa|aaa)*(b)/).captures, t.match(/(a+)(a{3})b/).captures.map(&:size)
p t.scan(/(a{50})(a*)(b)/).map { |g| g.map(&:size) }

# more groups than the inline capture pool holds
g17 = /(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)(k)(l)(m)(n)(o)(p)(q)/
u = ("z" * 100) + "abcdefghijklmnopq" + ("z" * 100)
p u.match(g17).captures.join, u.match(g17).begin(0)
p u.sub(/(z+)(a)(b)/) { "#{$1.size}#{$2}#{$3}" }.size

# gsub over a long subject, each match with groups
v = (1..200).map { |i| "k#{i}=v#{i}" }.join(";")
w = v.gsub(/k(\d+)=v(\d+)/) { $1 == $2 ? "ok" : "ng" }
p w.split(";").uniq, w.size

# the backtracking engine (a backreference) holding many entries at once
x = ("ab" * 100) + "ab"
p x.match(/(\w)(.*)\1/).captures.map(&:size), x.match(/(ab)(?:\1)+$/)[0].size
y = ("x" * 80) + "q" + ("x" * 80)
p y.match(/(x+)q\1/)[1].size, y.match(/(x*)(x+)q\2/).captures.map(&:size)
