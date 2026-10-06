# CRuby reopens its own ConditionVariable here and adds `hi` to it. The
# reopened class keeps #signal.
class ConditionVariable
  def hi = "mine"
end

cv = ConditionVariable.new
cv.signal
puts cv.hi
