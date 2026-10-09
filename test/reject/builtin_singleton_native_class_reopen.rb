# A constant singleton-class body cannot reopen a native class implicitly.
# spinel: reject-builtin-class: reopening the builtin class ConditionVariable is not supported
class << ConditionVariable
  def reachable_helper = :called
end
p ConditionVariable.new.class
p ConditionVariable.reachable_helper
