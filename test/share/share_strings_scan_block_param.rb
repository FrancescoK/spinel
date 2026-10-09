# spinel: gc-minor
# A match `scan` hands its block is a new String. A block parameter the
# program keeps and changes in place is bound to a shared handle of its own
# for each match, whatever form the call takes.

# statement form, matches kept in an Array and changed through the block
# parameter and through the Array
acc = []
"a1b2".scan(/[a-z]/) { |m| acc << m; m << "*" }
acc[0] << "!"
acc.each { |t| t << "?" }
p acc

# a String pattern, and a subject that is a variable
def tail_scan
  acc = []
  s = +"xabyab"
  s.scan("ab") { |m| acc << m; m << "*" }
end
p tail_scan
def keep_scan
  acc = []
  s = +"xabyac"
  s.scan(/a./) { |m| acc << m; m << "+" }
  acc
end
p keep_scan

# a pattern only known at run time
pat = Regexp.new("[a-c]")
runtime = []
"abc".scan(pat) { |m| runtime << m; m << "~" }
p runtime

# the block parameter shadows a local of the same name
m = "outer"
shadow = []
"pq".scan(/./) { |m| shadow << m; m << "*" }
p m, shadow

# matches stored in a Hash and in an ivar, changed later
class Scanner
  attr_reader :last, :all
  def initialize = (@all = {})
  def run
    "1 22".scan(/\d+/) { |m| @last = m; @all[m.dup] = m; m << "!" }
    @all.each_value { |v| v << "#" }
    self
  end
end
sc = Scanner.new.run
sc.last << "?"
p sc.last, sc.all

# a method that yields the match on
def each_match
  "ab cd".scan(/\w+/) { |m| yield m }
end
kept = []
each_match { |w| kept << w; w << "+" }
p kept

# the match handed to a method that stores it
def keep(a, s) = a << s
stored = []
"a1b2".scan(/\w\d/) { |m| keep(stored, m); m << "*" }
p stored

# nested scans, next and break
inner = []
"ab".scan(/./) { |m| "12".scan(/./) { |n| inner << m; inner << n; n << m; m << n } }
p inner
res = []
"abc".scan(/./) { |m| next if m == "b"; res << m; m << "!"; break if m == "c!" }
p res

# a proc that closes over the match
procs = []
"pq".scan(/./) { |m| procs << -> { m << "_"; m } }
p procs.map(&:call)
p procs.map(&:call)

# scan without a block still hands back new Strings
r = "a1b2".scan(/\w\d/)
r[0] << "!"
p r

# many matches kept across a collection
big = []
50.times do |i|
  "#{"t" * 40}#{i}".scan(/t{10}|\d+/) { |t| big << t; t << "i#{i}" }
end
GC.start
p big.size, big[0], big[-1], big.map(&:size).sum

# capture groups: several parameters take one String each
parts = []
"a1b2".scan(/([a-z])(\d)/) { |l, d| parts << l; parts << d; l << "-"; d << "#" }
p parts
letters = []
"a1b2".scan(/([a-z])(\d)/) { |l, d| letters << l; l << "<" }
p letters

# `$~` and `$1` read in the block
seen = []
"x1y2".scan(/[a-z]\d/) { |m| seen << m; p $~[0]; m << "!" }
p seen
groups = []
"a1b2".scan(/([a-z])\d/) { |m| groups << m; m << $1 }
p groups

# a scan that is the tail of a lambda or a proc answers its subject, with the
# matches it kept changed through the parameter
tail_acc = []
tail_l = -> { "ab".scan(/./) { |m| tail_acc << m; m << "!" } }
p tail_l.call
tail_p = proc { "cd".scan(/./) { |m| tail_acc << m; m << "?" } }
p tail_p.call
p tail_acc

# a local subject no other name holds and the block does not mention: the block
# writes only a local of its own and changes only the matches
def local_temp
  acc = []
  s = +"ab"
  s.scan(/./) { |m| up = m.upcase; acc << m; m << up }
  acc
end
p local_temp
