# Regexp.escape and quote answer a new String, and so does a class method's
# receiverless `name`, Module#name of the Class that is self there, even in
# a class with an attr reader of that name, which only its instances have.
# Kept beside a String changed through another name, each is a new handle
# around its bytes, a change through it showing through its other names.
# The class's frozen name stays frozen and the same object. A program
# class's own `escape`, its own `self.name`, and an instance's receiverless
# `name` (its reader) answer a String another name holds.
$all = []
buf = +"buf"
$all << buf
buf << "!"

src = +"plain"
e = Regexp.escape(src)
q = Regexp.quote(ARGV.size > 0 ? "x" : "a+b")
$all << e
$all << q
e << "?"
q << "#"
p src, e, q

class NotFound < StandardError
  attr_reader :model
  def initialize(msg, model)
    super(msg)
    @model = model
    $all << model
  end
end
class Rec
  attr_reader :name
  def initialize(n) = @name = n
  def self.find(id)
    raise NotFound.new("no #{name} #{id}", name) if id.nil?
    id
  end
  def self.who
    n = name
    $all << n
    n
  end
  def self.same = name.equal?(name)
  def self.names = [1].map { |i| name }
  def grab
    n = name
    $all << n
    n
  end
end
class Sub < Rec
end
r = Rec.new(buf)
begin
  Rec.find(ARGV.size > 0 ? 1 : nil)
rescue NotFound => ex
  p ex.message, ex.model, ex.model.frozen?
end
p Rec.who, Sub.who, Rec.same, Rec.names, Rec.who.frozen?
g = Sub.new(+"own").grab
g << "?"
p r.name, g

class Esc
  def self.escape(s) = s
end
mine = +"mine"
me = Esc.escape(mine)
$all << me
me << "?"
p mine

class Labeled
  def self.name = $label
  def self.take
    n = name
    $all << n
    n
  end
end
$label = +"lab"
t = Labeled.take
t << "?"
p $label
p $all
