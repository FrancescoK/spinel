# A String instance variable that no write has set yet is nil, and a call on
# it runs its arguments before it raises nil's NoMethodError. A Range
# literal's end that a call answers, an Integer or nil, is held as it is
# while they run: nil there is an open end, as CRuby reads it. Converted to
# an Integer as it was held, a nil end raised TypeError, on a String as on
# nil.

$log = []
def stop(at)
  $log << "stop"
  at < 0 ? nil : at
end

class Pier
  def initialize(name, known) = (@name = name if known)
  def from(at) = @name.slice(1..stop(at))
  def tail(at) = @name[stop(at)..]
  def before(at) = @name.slice(stop(at)...5)
  def both(a, z) = @name[stop(a)..stop(z)]
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

def report(name, pier)
  [2, -1].each do |at|
    e = at < 0 ? "nil" : at.to_s
    show("#{name} slice(1..#{e})") { pier.from(at) }
    show("#{name} [#{e}..]") { pier.tail(at) }
    show("#{name} slice(#{e}...5)") { pier.before(at) }
    show("#{name} [#{e}..#{e}]") { pier.both(at, at) }
  end
end

report("Seongsu", Pier.new("Seongsu", true))
report("Achasan", Pier.new("Achasan", false))
