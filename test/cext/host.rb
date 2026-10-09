# Provides a real compiler-generated class/symbol bank for the C runtime host.
class CextTestError < RuntimeError
  attr_accessor :detail
end
error = CextTestError.new("fixture")
error.detail = 23
raise error unless error.detail == 23
