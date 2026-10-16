# const_defined? with a name known only at run time, on a module, on self
# in a class method and in a module body (io-event picks its selector this
# way), answers as the literal name would; a name with no leading capital
# raises NameError.

module Sel
  class Select; end
  class KQueue; end
  LIMIT = 3
  selectors = [:URing, :EPoll, :KQueue, :Select]
  BEST = const_get(selectors.find { |name| const_defined?(name) })
  def self.has?(name) = const_defined?(name)
end

p Sel::BEST
[:Select, "Select", :LIMIT, :URing, "Nope"].each { |n| p [n, Sel.has?(n)] }
n = [:KQueue, :Nope]
p n.map { |x| Sel.const_defined?(x) }
begin
  Sel.has?("lower")
rescue NameError => e
  p e.message
end
