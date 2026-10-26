# Symbol#to_proc over a Symbol value that is not a local: a call's result,
# a method's return, an instance variable. The value is read once, where
# to_proc runs, and the proc sends it to each receiver it is called with
p ("up" + "case").to_sym.to_proc.call("ab")
p ["ab", "cd"].map(&("up" + "case").to_sym.to_proc)
p ["ab"].map(&"upcase".to_sym)

def nm = "size".to_sym
p nm.to_proc.call("abc")
p %w[a bb].map(&nm.to_proc)

class Pick
  def initialize(s) = @s = s
  def call_on(v) = @s.to_proc.call(v)
  def map_amp(a) = a.map(&@s)
  def map_to_proc(a) = a.map(&@s.to_proc)
end
k = Pick.new(ARGV.empty? ? :upcase : :downcase)
p k.call_on("ab"), k.map_amp(["cd"]), k.map_to_proc(["ef"])

# the Symbol expression runs once, when to_proc does, not once per call
$runs = 0
def counted
  $runs += 1
  ("re" + "verse").to_sym
end
pr = counted.to_proc
p pr.call("abc"), pr.call("xyz"), $runs
p %w[ab cd ef].map(&counted.to_proc), $runs
p (counted).to_proc.call("12"), $runs

# in its place among its neighbours: left to right
order = []
p [(order << 1; "a"), (order << 2; :upcase).to_proc.call("q"), (order << 3; "c")], order

# a Proc a computed Symbol's to_proc wrote to a local is typed from its calls
up = ("up" + "case").to_sym
stored = up.to_proc
p stored.call("cd"), stored.call("ef")
