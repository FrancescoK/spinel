# Beyond the gem: a class that includes an Importer module calls its functions bare.
require "fiddle/import"
module M
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int abs(int)"
end
class U
  include M
  def a(x) = abs(x)
end
p U.new.a(-3)
begin
  M.nothere(1)
rescue NoMethodError
  puts "NoMethodError"
end
