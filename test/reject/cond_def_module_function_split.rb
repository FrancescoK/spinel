# spinel: reject-subclass: CallNode `m#__cond
# The arms of a run-time conditional def sit on both sides of a bare
# module_function: only the second is a module function, so which one M.m
# reaches depends on the condition (CRuby: NoMethodError here).
module M
  unless ENV["SPINEL_TEST_NEVER_SET"]
    def m = 1
  end
  module_function
  if ENV["SPINEL_TEST_NEVER_SET"]
    def m = 2
  end
end
begin
  p M.m
rescue NoMethodError => e
  p e.message
end
