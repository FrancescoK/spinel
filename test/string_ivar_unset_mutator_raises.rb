# A String instance variable that no initialize sets first is nil until a
# method sets it, and a mutator called on it raises nil's NoMethodError
# once its arguments have run. Its frozen check read the nil as a frozen
# String, "can't modify frozen String: nil" (FrozenError), setbyte raised
# IndexError and slice! answered nil. Set, each mutator changes the String
# in the variable.

$log = []
def note(v) = ($log << v; v)

def show(label)
  r = begin
    yield.inspect
  rescue NoMethodError => e
    "#{e.class} #{e.message}"
  end
  puts "#{label}: #{$log.join(" ")} -> #{r}"
  $log.clear
end

class Pier
  def initialize(known) = (@name = +"Seongsu" if known)
  def add(s) = (@name << note(s); @name)
  def tail(s) = (@name.concat(note(s)); @name)
  def lead(s) = (@name.prepend(note(s)); @name)
  def put(i) = (@name.insert(note(i), "-"); @name)
  def set_at(i) = (@name[note(i)] = "O"; @name)
  def set_byte(i) = (@name.setbyte(note(i), 115); @name)
  def cut(i) = (@name.slice!(note(i)); @name)
  def shout = (@name.upcase!; @name)
  def swap(s) = (@name.sub!(note(s), "0"); @name)
  def turn(s) = (@name.tr!(note(s), "u"); @name)
  def squash = (@name.squeeze!; @name)
  def flip = (@name.reverse!; @name)
  def add_bytes(s) = (@name.append_as_bytes(note(s)); @name)
  def renew(s) = (@name.replace(note(s)); @name)
  def wipe = (@name.clear; @name)
  def answer(s) = (@name << note(s))
end

[true, false].each do |known|
  k = known ? "Seongsu" : "nil"
  show("#{k} <<") { Pier.new(known).add(" Ro") }
  show("#{k} concat") { Pier.new(known).tail(" Ro") }
  show("#{k} prepend") { Pier.new(known).lead("Ttukseom ") }
  show("#{k} insert") { Pier.new(known).put(3) }
  show("#{k} []=") { Pier.new(known).set_at(2) }
  show("#{k} setbyte") { Pier.new(known).set_byte(0) }
  show("#{k} slice!") { Pier.new(known).cut(0) }
  show("#{k} upcase!") { Pier.new(known).shout }
  show("#{k} sub!") { Pier.new(known).swap("o") }
  show("#{k} tr!") { Pier.new(known).turn("o") }
  show("#{k} squeeze!") { Pier.new(known).squash }
  show("#{k} reverse!") { Pier.new(known).flip }
  show("#{k} append_as_bytes") { Pier.new(known).add_bytes("!") }
  show("#{k} replace") { Pier.new(known).renew("Achasan") }
  show("#{k} clear") { Pier.new(known).wipe }
  show("#{k} << as a value") { Pier.new(known).answer("!") }
end
