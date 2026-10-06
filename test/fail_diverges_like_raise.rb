def tail_fail(value)
  return value unless value.empty?

  fail ArgumentError, "tail"
end

def if_fail(value)
  if value.empty?
    fail ArgumentError, "if"
  else
    value
  end
end

def case_fail(kind)
  case kind
  when :a then "a"
  else fail ArgumentError, "case"
  end
end

def fail_message_only(value)
  return value unless value.empty?

  fail "runtime"
end

def try(label)
  puts yield
rescue => e
  puts "#{label}: #{e.class} #{e.message}"
end

try("tail") { tail_fail("") }
try("if") { if_fail("") }
try("case") { case_fail(:b) }
try("message") { fail_message_only("") }
puts tail_fail("x"), if_fail("y"), case_fail(:a), fail_message_only("z")

def case_all_diverge(kind)
  case kind
  when :a then return "a"
  else fail ArgumentError, "other"
  end
end

try("case_all") { case_all_diverge(:b) }
puts case_all_diverge(:a)

# a block whose last statement is `fail` (after a `next`) yields no value
try("block") { [1, 2].map { |x| next x * 10 if x < 2; fail ArgumentError, "block" } }
p [1].map { |x| next x * 10 if x < 2; fail ArgumentError, "block" }

# a class's own `fail` is an ordinary method and keeps its value
class Grader
  def fail(score) = score < 50 ? "F#{score}" : "P#{score}"
  def last(score)
    return "skip" if score > 90
    fail score
  end
  def all(xs) = xs.map { |x| next "skip" if x > 90; fail x }
end
puts Grader.new.last(20)
p Grader.new.all([95, 70])
