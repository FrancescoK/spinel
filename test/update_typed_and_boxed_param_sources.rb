# update into a hash parameter of several hash parameters, some typed at
# every call and some boxed: the typed ones' keys and values are still
# evidence for the receiver, whichever position the boxed one takes
def two(obj, a, b) = obj.update(a, b)
p two({ "a" => 1 }, { "x" => "s" }, { "c" => 3 })
p two({ "a" => 1 }, { "y" => "t" }, { "d" => nil })

def rev(obj, b, a) = obj.update(b, a)
p rev({ "a" => 1 }, { "c" => 3 }, { "x" => "s" })
p rev({ "a" => 1 }, { "d" => nil }, { "y" => "t" })

def three(obj, a, b, c) = obj.update(a, b, c)
p three({ 1 => 2 }, { "k" => :v }, { 3 => 4 }, { 5 => 1.5 })
p three({ 1 => 2 }, { "k" => :w }, { "z" => nil }, { 6 => 2.5 })

# into an instance variable's Hash, nothing checks the boxed one at a call,
# so the typed ones beside it do not decide the receiver's kinds
class Acc
  attr_reader :h

  def initialize = @h = {}
  def add(a, b) = @h.update(a, b)
  def add_rev(b, a) = @h.update(b, a)
end
acc = Acc.new
acc.add({ "a" => 1 }, { "s" => 1.5 })
acc.add({ "b" => 2 }, { :t => "x" })
acc.add_rev({ 7 => [1] }, { "c" => 3 })
acc.add_rev({ "u" => nil }, { "d" => 4 })
p acc.h
