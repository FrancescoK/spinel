# `recv[key]` with a String or Symbol key on a receiver of more than one class
# calls a Proc or a Method with the key, and a class's or module's own
# `self.[]`, as CRuby does, where it answered nil.
class Table
  def self.[](key) = "table:#{key}"
end
module Tbl
  def self.[](key) = "mod:#{key}"
end

def lookup(recv, key) = recv[key]

p lookup(->(k) { "proc:#{k}" }, "x")
p lookup(Table, "x")
p lookup(Tbl, "y")
p lookup({ "x" => "hash" }, "x")
p lookup(->(k) { k.to_s * 2 }, :ab)
p lookup(Table, :sym)
p lookup(10.method(:+), 5)
