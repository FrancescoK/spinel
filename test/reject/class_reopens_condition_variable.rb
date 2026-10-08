# CRuby reopens its own ConditionVariable here and adds `hi` to it. The
# reopened class keeps #signal.
# spinel: reject-builtin-class: reopening the builtin class ConditionVariable is not supported
class ConditionVariable
  def hi = "mine"
end

cv = ConditionVariable.new
cv.signal
puts cv.hi
