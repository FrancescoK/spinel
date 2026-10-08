# An EMPTY container literal carries a DEFAULT kind, not evidence: a bare `{}`
# reads as the String-keyed variant, so it contradicted every Symbol-keyed
# seed -- though it has no keys to disagree about, and the seed is the only
# thing in the program that says which kind it is (#4025). The seed wins, and
# the literal is built at it.
# spinel: rbs-seed-run
class C
  def sym_hash
    {}
  end

  def str_hash
    {}
  end

  def int_array
    []
  end

  def real_str_hash
    { "k" => 1 }
  end
end

c = C.new
p c.sym_hash
p c.str_hash
p c.int_array
p c.real_str_hash
c.sym_hash[:a] = 1
p c.int_array.size
