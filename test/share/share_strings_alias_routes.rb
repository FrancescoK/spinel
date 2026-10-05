# Flag-only: without the flag (as on master) the C for these routes does not compile.
# Four routes by which a String reaches a second name, each answered with
# the String itself under --share-strings (master refuses them):
# a reader on a boxed receiver, a proc that stores its parameter, a scan
# match the block keeps or changes, and a global's Array.
T = Struct.new(:text)
s = [T.new(+"value"), 0][0]
t = s.text; t << "!"; t.upcase!
p s.text
class U
  attr_reader :text
  def initialize = (@text = +"u")
  def bump = (@text << "+")
end
u = [U.new, 0][0]
v = u.text; v << "!"; u.bump
p u.text, v
D = Data.define(:text)
d = [D.new(text: +"d"), 0][0]
w = d.text; w << "!"
p d.text

kept = []
blk = proc { |i, x| kept[i] = x }
blk.call(0, +"a"); blk.call(1, 2)
kept[0] << "b"
lam = ->(x) { kept << x }
lam.(+"c"); lam.(3)
kept[2] << "d"
p kept

acc = []
"a1b2".scan(/[a-z]/) { |m| acc << m; m << "*" }
"c3".scan(/([a-z])(\d)/) { |m, n| acc << m; m << n }
p acc

$b = []
$b << +"y"
$b.push(+"z")
$b.each { |y| y << "?" }
$b[1] << "!"
$b.map { |y| y << "." }
p $b
