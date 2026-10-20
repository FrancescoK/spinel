# A call on a receiver that can be nil runs its arguments, then raises nil's
# NoMethodError. An argument that is an Integer or nil is the method's to
# convert, after that: its nil is a TypeError only from a receiver that has
# the method, and a method of the program's own can take it. Converted
# first, a nil argument raised TypeError on a nil receiver, and on a local's
# object whose method takes nil.

$log = []
def stop(at)
  $log << "stop"
  at < 0 ? nil : at
end

def show(label)
  r = begin
    yield.inspect
  rescue NoMethodError, TypeError => e
    "#{e.class} #{e.message}"
  end
  puts "#{label}: #{$log.join(" ")} -> #{r}"
  $log.clear
end

# an instance variable that no write has set
class Pier
  def initialize(name, known) = (@name = name if known)
  def slice(at) = @name.slice(stop(at))
  def pair(at) = @name[stop(at), 3]
  def bytes(at) = @name.byteslice(stop(at))
  def byte(at) = @name.getbyte(stop(at))
  def wide(at) = @name.center(stop(at))
  def find(at) = @name.index("o", stop(at))
  def times(at) = @name * stop(at)
  def unpack(at) = @name.unpack1("C", offset: stop(at))
  def match(at) = @name.match?(/o/, stop(at))
  def local(at)
    i = stop(at)
    @name.slice(i)
  end
end

# a parameter, and locals the program sets to nil
def param_slice(name, at) = name.slice(stop(at))
def param_center(name, at) = name.center(stop(at))

def local_bytes(known, at)
  name = "Kondae"
  name = nil unless known
  name.byteslice(stop(at))
end

class Gate
  def initialize(name) = (@name = name)
  def pick(at) = at.nil? ? "#{@name} open" : "#{@name} #{at}"
end

def local_gate(known, at)
  gate = Gate.new("Children's Grand Park")
  gate = nil unless known
  gate.pick(stop(at))
end

def report(label, pier, name, known)
  [2, -1].each do |at|
    e = at < 0 ? "nil" : at.to_s
    show("#{label} slice(#{e})") { pier.slice(at) }
    show("#{label} [#{e}, 3]") { pier.pair(at) }
    show("#{label} byteslice(#{e})") { pier.bytes(at) }
    show("#{label} getbyte(#{e})") { pier.byte(at) }
    show("#{label} center(#{e})") { pier.wide(at) }
    show("#{label} index(\"o\", #{e})") { pier.find(at) }
    show("#{label} * #{e}") { pier.times(at) }
    show("#{label} unpack1(offset: #{e})") { pier.unpack(at) }
    show("#{label} match?(/o/, #{e})") { pier.match(at) }
    show("#{label} slice(i = #{e})") { pier.local(at) }
    show("#{label} param slice(#{e})") { param_slice(name, at) }
    show("#{label} param center(#{e})") { param_center(name, at) }
    show("#{label} local byteslice(#{e})") { local_bytes(known, at) }
    show("#{label} local pick(#{e})") { local_gate(known, at) }
  end
end

report("Seongsu", Pier.new("Seongsu", true), "Jayang", true)
report("nil", Pier.new("Achasan", false), nil, false)
