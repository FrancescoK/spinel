# set_backtrace given an Array whose type only the run time knows -- the
# `callstack.map(&:to_s)` of a lambda parameter -- stores its Strings.
require "set"
class Gone < StandardError; end

report = ->(message, callstack) do
  error = Gone.new(message)
  error.set_backtrace(callstack.map(&:to_s))
  error
end

stacks = [[:here, :there], ["x:2", "y:3"], [1, 2], []]
stacks.each { |cs| p report.("m", cs).backtrace }
p report.("d", Set[:a, :b]).backtrace
p report.("e", [:sym]).message
