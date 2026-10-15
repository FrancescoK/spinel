# An object with the default inspect lists its instance variables sorted,
# broken across lines when wide; a class's own inspect or pretty_print is
# what pp prints. The addresses differ from run to run, so they are masked.
require "pp"

class Node
  def initialize(name, kids = [])
    @name = name
    @kids = kids
  end
end

class Custom
  def initialize = @secret = 1
  def inspect = "#<Custom!>"
end

class Pretty
  def pretty_print(q)
    q.group(1, "<P", ">") { q.breakable; q.text "body" }
  end
end

class Bare; end

def masked(obj) = obj.pretty_inspect.gsub(/0x\h+/, "0xADDR")

print masked(Node.new("leaf"))
print masked(Node.new("root", [Node.new("a" * 30), Node.new("b" * 30)]))
print masked(Custom.new)
print masked(Pretty.new)
print masked(Bare.new)
print masked([Pretty.new, Custom.new])
