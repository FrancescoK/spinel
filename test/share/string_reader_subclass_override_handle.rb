# A receiverless read of an attr reader whose field holds a shared String,
# where a subclass overrides the reader with a def, answers each class's own
# String: the field's String for the reader's class, a new String an override
# builds, and the shared String an override answers from a field of its own.
# A change through the read shows in that String.
class Parent
  attr_reader :name
  def initialize = (@name = +"name")
  def change
    s = name
    s << "!"
    s
  end
end
class Fresh < Parent
  def name = (@name + "fresh")
end
class Own < Parent
  def initialize
    super
    @o = +"o"
  end
  def name = @o
  def o = @o
end
class Grand < Own
end

f = Fresh.new
p [f.change, f.instance_variable_get(:@name)]
w = Own.new
p [w.change, w.o, w.instance_variable_get(:@name)]
g = Grand.new
g.change
p [g.change, g.o]
x = Parent.new
x.change
p [x.change, x.name]

# an override answering an element read off a typed receiver: the read
# dispatches on the runtime class, and the element is the String itself
CE = [+"cst"]
class PE
  attr_reader :name
  def initialize = (@name = +"name")
end
class CE2 < PE
  def name = CE[0]
end
ce = CE2.new
re = ce.name
re << "!"
p re, ce.name, re.equal?(ce.name), CE
pe = PE.new
xe = pe.name
xe << "?"
p pe.name, [pe, CE2.new].map { |o| o.name }
