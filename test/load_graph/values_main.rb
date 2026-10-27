# Main's instance variables, globals and constants first written in a
# required file (values_lib.rb) are nil, or not defined, before its require
# and hold its values after it, also in a loop; the ones main writes after
# the require are not there yet when the required file runs.
p defined?(@level)
p $total
p defined?(LIMIT)
require_relative "values_lib"
p @level + 1
p $total * 2
p LIMIT
s = 0
i = 0
while i < @level
  s += $total + LIMIT
  i += 1
end
p s
@early = 3
$late = 4
LATE = 5
p @early + $late + LATE
