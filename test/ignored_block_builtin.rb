# A literal block given to a builtin method that ignores it: CRuby runs the
# call as if no block were given. A boxed receiver (read out of a mixed
# Array), a nil-or-value one and a typed one all answer the blockless call,
# and the block never runs. A method of the program's own with the name
# keeps its block.

class Box
  def at(i) = yield(i)
end

def boxed(k)
  log = []
  p [0.3, :x][k].rationalize { log << 1 }
  p [7, :x][k].rationalize(0.1) { log << 2 }
  p [Rational(-5, 2), :x][k].equal?(:s) { log << 3 }
  p [[1.5, 2.5], :x][k].first(1) { log << 4 }
  p [[1, 2], :x][k].rotate(1) { log << 5 }
  p [[1, 2, 1], :x][k].count(1) { log << 7 }
  p ["ab", :x][k].instance_variable_get(:@a) { log << 8 }
  p [(0.5..2.5), :x][k].eql?(0.5..2.5) { log << 9 }
  p [/a/, :x][k] =~ "cab"
  p [/a/, :x][k].=~("cab") { log << 10 }
  p [+"s", :x][k].prepend("x") { log << 11 }
  p [[1], :x][k].insert(1, 2) { log << 12 }
  p [:ab, :x][k].upcase(:ascii) { log << 13 }
  p log
end

def nilable(k)
  log = []
  r = k == 0 ? nil : (0.5..2.5)
  p r.equal?(1) { log << 1 }
  q = k == 0 ? Rational(3, 4) : nil
  p q.rationalize { log << 2 }
  p q.eql?(Rational(3, 4)) { log << 3 }
  p log
end

def typed
  log = []
  p 0.3.rationalize { log << 1 }
  p Time.at(0).utc.round { log << 2 }
  p [1, 2, 1].count(1) { log << 3 }
  p [3, 4].rotate(1) { log << 4 }
  p log
end

boxed(ARGV.size)
nilable(ARGV.size)
typed
p Box.new.at(3) { |v| v * 2 }
