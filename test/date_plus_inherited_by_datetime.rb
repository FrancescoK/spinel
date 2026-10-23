# spinel: int64
# Date#+ and Date#- serve DateTime too, as CRuby's one method does for both
# classes: a DateTime adds and subtracts days, day fractions and dates with
# its time of day and offset kept. An alias a program takes of + or - in
# Date (activesupport's plus_without_duration / minus_without_duration, then
# + and - redefined over them) is then the method a DateTime runs as well,
# where a DateTime#+ of its own would have been another method, and the
# alias settling refused the program.
require "date"
d = Date.new(2026, 1, 30)
dt = DateTime.new(2026, 1, 30, 12, 30, 15, "+09:00")
puts d + 1, d - 1, d + Rational(1, 2), d - Rational(3, 2), (d + 0.5).day_fraction, d - Date.new(2026, 1, 1), d - dt
puts dt + 1, dt - 1, dt + Rational(1, 4), dt - Rational(1, 4), dt + 0.5, (dt - Date.new(2026, 1, 30)).to_f, dt - DateTime.new(2026, 1, 30, 0, 0, 0, "+09:00")
puts (dt + 1).hour, (dt + 1).offset, (dt - 2).class, (d + 1).class
class Date
  def plus_with_duration(other)
    other.is_a?(Array) ? plus_without_duration(other[0]) : plus_without_duration(other)
  end
  alias_method :plus_without_duration, :+
  alias_method :+, :plus_with_duration
  def minus_with_duration(other)
    other.is_a?(Array) ? minus_without_duration(other[0]) : minus_without_duration(other)
  end
  alias_method :minus_without_duration, :-
  alias_method :-, :minus_with_duration
end
puts d + [3], dt + [3], (dt + [3]).min, d - [3], dt - [Rational(1, 2)], (dt - [Rational(1, 2)]).hour
begin
  d + "x"
rescue TypeError => e
  puts e.message
end
