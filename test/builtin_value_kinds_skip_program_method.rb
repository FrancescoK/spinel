# A call on a value of a core class (a Regexp, a Range, a Time, a Rational, a
# Complex or a MatchData, as much as an Integer or a String) runs that class's
# own method, not a program class's method of the same name. The reachability
# pass knew only some of those value kinds and marked a call on the others by
# bare name, so a program's `freeze` (or `source`, `year`, ...) stayed alive
# because `/re/.freeze` was somewhere in the program, with all it calls: every
# program requiring date kept Date#freeze that way. A Probe is built here, so
# its methods wait only for a call that can reach them; the seven methods named
# like a core value's and the helpers they call are never run and are not
# emitted. The infer-test assertion checks the C. The answers are CRuby's.
class Probe
  def label
    "probe"
  end

  def freeze
    helper_freeze
  end

  def source
    helper_source
  end

  def to_a
    helper_to_a
  end

  def year
    helper_year
  end

  def numerator
    helper_numerator
  end

  def real
    helper_real
  end

  def pre_match
    helper_pre_match
  end

  def helper_freeze = 1
  def helper_source = 2
  def helper_to_a = 3
  def helper_year = 4
  def helper_numerator = 5
  def helper_real = 6
  def helper_pre_match = 7
end

puts Probe.new.label
re = /a(b)c/
puts re.source
puts re.freeze.frozen?
puts (1..4).to_a.inspect
puts Time.at(0, in: "UTC").year
puts Rational(3, 6).numerator
puts Complex(2, 5).real
puts "xabcx".match(re).pre_match
