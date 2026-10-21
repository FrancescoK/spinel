# A value that is a class or a String calls the class method of a String
# builtin's name, whatever its parameters: `(...)`, a **rest beside the
# positionals, or a *rest alone (#9878).

class PB
  def self.split(...) = ["kept"]
  def self.me = itself
end

class PK
  def self.split(s, n, **kw) = ["pk", s, n.to_s, kw.size.to_s]
end

class PR
  def self.split(*a) = a.map(&:to_s)
end

def pick(i)
  case i
  when 0 then PB
  when 1 then PK
  when 2 then PR
  else +"a;b;c"
  end
end

4.times { |i| p pick(i).split(";", 2) }
x = ARGV.size == 0 ? PB.me : +"a;b"
p x.split(";", 2)
y = ARGV.size == 1 ? PB : +"c;d"
p y.split(";", 2)
