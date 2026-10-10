# A constant read before its assignment has run is CRuby's NameError, and
# defined?, const_defined? and const_get say it is not there yet; after the
# assignment they find it. A constant whose assignment no read can precede
# (one in a body that only defines things first) stays a plain read.

def say
  yield
rescue NameError => e
  puts "NameError: #{e.message}"
end

# a class held in a variable names itself in the error, a Class.new one too
module Named; end
holder = Named
anon = Class.new
say { p holder::ONLY }
begin
  p anon::ONLY2
rescue NameError => e
  puts e.message.sub(/0x\h+/, "0xADDR")
end
Named::ONLY = 3
anon::ONLY2 = 4
p holder::ONLY, anon::ONLY2

# the receiver of such a read runs once, raising or not
module Counted; end
$picks = 0
def pick
  $picks += 1
  Counted
end
say { p pick::CNT }
p $picks
Counted::CNT = 5
p pick::CNT, $picks
p(pick::CNT + 1, $picks)

# String mutators on a flagged constant read through a class held in a variable
# or a call, and through the class itself
module Mut; end
$muts = 0
def mut_pick
  $muts += 1
  Mut
end
mk = Mut
say { mk::MBUF << "y" }
say { mut_pick::MBUF.concat("z") }
say { mut_pick::MAPP << "?" }
p $muts
module Mut
  MBUF = +"a"
  MUP = +"b"
  MREP = +"c"
  MINS = +"d"
  MIDX = +"e"
  MAPP = +"f"
end
mk::MBUF << "y"
mk::MUP.upcase!
mk::MREP.replace("33")
mk::MINS.insert(0, "D")
mk::MIDX[0] = "E"
mut_pick::MAPP << "!"
mut_pick::MAPP.concat("?")
p Mut::MBUF, Mut::MUP, Mut::MREP, Mut::MINS, Mut::MIDX, Mut::MAPP, $muts

# a rescue clause that names a constant not assigned yet is a NameError, with
# an Exception after it too
def classify
  raise TypeError, "kept"
rescue GONE, TypeError
  "rescued"
end
def classify_catchall
  raise TypeError, "kept"
rescue GONE2, Exception
  "rescued"
end

# constants assigned first, in bodies that only define things, are plain reads
class Plain
  attr_reader :n
  KEEP = 7
  OTHER = KEEP * 2
  def initialize = @n = OTHER
  def keep = KEEP
end
FIRST = 5
SECOND = FIRST + 1
def second = SECOND

# a read at the top level
say { p LATE }
say { p defined?(LATE) }
say { p Object.const_defined?(:LATE) }
say { p Object.const_get(:LATE) }

# a method called before the assignment, and one called after it
def early = defined?(LATE)
def read_late = LATE
def read_late_ternary = defined?(LATE) ? LATE : :fallback
p early
say { read_late }
p read_late_ternary

LATE = ArgumentError
p early, read_late, read_late_ternary
p Object.const_defined?(:LATE), Object.const_get(:LATE)

# values of other kinds
say { p COUNT + 1 }
say { p NAMES.size }
say { p RATIO * 2 }
say { p FLAG }
say { p LOG }
COUNT = 41
NAMES = %w[a b]
RATIO = 1.5
FLAG = nil
LOG = +"start"
LOG << "-more"
p COUNT + 1, NAMES.size, RATIO * 2, FLAG, LOG

# a constant of a module: read from the module's methods, by path, by name
module Cfg
  def self.limit = LIMIT
  def self.ready? = defined?(LIMIT)
  def self.named = Cfg.const_defined?(:LIMIT)
  def self.listed = Cfg.constants.include?(:LIMIT)
end
say { Cfg.limit }
say { p Cfg::LIMIT }
say { p Cfg::DEPTH }
say { p defined?(Cfg::LIMIT) }
say { p Cfg::TITLE }
p Cfg.ready?, Cfg.named, Cfg.listed

module Cfg
  LIMIT = 10
  TITLE = +"cfg"
end
Cfg::DEPTH = 3
Cfg::TITLE << "!"
p Cfg::TITLE
p Cfg.limit, Cfg::LIMIT, Cfg::DEPTH
p Cfg.ready?, Cfg.named, Cfg.listed
p defined?(Cfg::LIMIT)

# the operator writes read the constant first, except ||=, which assigns
say { AND1 &&= 1 }
say { PLUS1 += 1 }
say { Cfg::PAND &&= 1 }
say { Cfg::PPLUS += 1 }
OR1 ||= 5
OR2 ||= nil
Cfg::POR ||= 6
p OR1, OR2, Cfg::POR
AND1 = 2
AND1 &&= 9
PLUS1 = 3
PLUS1 += 4
p AND1, PLUS1

# a String constant appended to before its assignment
def append_late = APPENDED << "!"
say { append_late }
APPENDED = +"s"
p APPENDED

# a constant read through a class held in a variable
module Left; end
module Right; end
sel = [Left, Right][ARGV.size]
say { p sel::SW }
module Left
  SW = 1
end
module Right
  SW = 2
end
p sel::SW

# a class method that reads a constant of its own class
class Box
  def self.size = SIZE
  def size = SIZE
end
say { Box.size }
say { Box.new.size }
class Box
  SIZE = 4
end
p Box.size, Box.new.size

# a constant assigned in a branch that runs later
say { p WARM }
if ARGV.size < 5
  WARM = :warm
end
p WARM

# the settled constants still answer
p Plain.new.n, Plain.new.keep, second, defined?(SECOND), Object.const_defined?(:SECOND)

say { p classify }
say { p classify_catchall }
GONE = ArgumentError
GONE2 = KeyError
p classify, classify_catchall

# a reassigned constant answers its latest value
ONCE = 1
p ONCE
ONCE = 2
p ONCE
