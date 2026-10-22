# spinel: reject-subclass: CallNode `m#__cond
# A bare public, even nested in another statement, ends module_function's
# mode, so the arms after it are not module functions (CRuby: NoMethodError).
module M
  module_function
  public if true

  if ENV["SPINEL_TEST_NEVER_SET"]
    def m = 1
  else
    def m = 2
  end
end
begin
  p M.m
rescue NoMethodError => e
  p e.message
end
