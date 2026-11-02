# extended: extend self in a module fires the module's extended hook on itself
module M
  def self.extended(o) = puts("ext #{o}")
  extend self
  def hi = "hi"
end
puts M.hi
