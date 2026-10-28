# Every constant-write form has a history in the load record, including
# the targets of a multiple assignment and a literal-name const_set.
A, B = [1, 2]
C = 3
C ||= 4
C &&= 5
C += 6
module Values
  G = 0
end
Values::D, Values::E = [7, 8]
Values::F = 9
Values::F ||= 10
Values::F &&= 11
Values::F += 12
Values.const_set(:G, 13)
p A, B, C, Values::D, Values::E, Values::F, Values::G

# A block, lambda or method may write after its defining statement.
def run = yield
p(run { RATE = 3.5 })
p(run { LIST = [1] })
run { H, I = [14, 15] }
run { Values::J, Values::K = [16, 17] }
run { Values::L = 18 }
run { Values::L ||= 19 }
run { Values::L &&= 20 }
run { Values::L += 21 }
run { M ||= 22 }
run { M &&= 23 }
run { M += 24 }
module Values
  LATER = -> { N = 25 }
  O = 0
  def self.assign = Values.const_set(:O, 26)
end
Values::LATER.call
Values.assign
p RATE, LIST, H, I, Values::J, Values::K, Values::L, M, Values::N, Values::O
