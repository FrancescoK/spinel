# `h.slice(*names)` with a splat of unknown length branches on the length of
# the Array the splat makes, a call the desugaring marks the builtin's alone.
# Its nil-ness is the builtin's too: a class of the program whose `length`
# answers nil is no target of that probe, so the probe stays a plain Integer
# and compares as one.
class NullList
  def length = nil
end
H = { a: 1, b: 2, c: 3 }
STATE = {}
def rme(names)
  results = {}
  H.each { |k, v| results[k] = v if Array(names).include?(k) }
  results.slice(*names)
end
STATE[:names] = [:a, :c]
p rme(STATE[:names])
STATE[:names] = :b
p rme(STATE[:names])
p NullList.new.length
