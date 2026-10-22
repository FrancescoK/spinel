# spinel: reject-subclass: CallNode `m#__cond
# Two ifs with no else: maybe no arm runs, and CRuby's NoMethodError then
# names the module, where the dispatcher's raise names an instance.
module M
  module_function

  if ENV["SPINEL_TEST_NEVER_SET"]
    def m = 1
  end
  if ENV["SPINEL_TEST_NEVER_SET_EITHER"]
    def m = 2
  end
end
begin
  p M.m
rescue NoMethodError => e
  p e.message
end
