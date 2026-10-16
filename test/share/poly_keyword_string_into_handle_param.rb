# spinel: gc-minor
# A String variable passed as a keyword through a call on a boxed receiver,
# to an arm whose keyword is the shared handle, binds that handle.
class Reporter
  def initialize
    @subscribers = []
  end

  def subscribe(sub) = @subscribers << sub

  def report(error, context: {}, source:)
    @subscribers.each do |subscriber|
      subscriber.report(error, context: deep_dup(context), source: source)
    end
    nil
  end

  def deep_dup(value)
    if value.is_a?(Hash)
      copy = value.dup
      value.each_pair { |key, item| copy[key] = deep_dup(item) }
      copy
    elsif value.is_a?(Array)
      value.map { |item| deep_dup(item) }
    else
      value.dup
    end
  end
end

class Sub
  def report(error, context: {}, source: "x")
    puts "#{error.message} #{context} #{source}"
  end
end

class Marker
  def report(error, context: {}, source: "x")
    source << "!"
    puts "marked #{error.message} #{source}"
  end
end

class Other
  def report(error, context: {}, source: "x")
    puts "other #{source.size}"
  end
end

r = Reporter.new
r.subscribe(Sub.new)
r.report(RuntimeError.new("boom"), context: { a: [1, 2] }, source: "web")
r.report(RuntimeError.new("bang"), source: "application")

# the callee appends to the String it was given: the caller's variable sees it
def tell(who, error, source)
  who.report(error, source: source)
  source
end
s = +"tag"
puts tell(Marker.new, RuntimeError.new("e1"), s)
puts s
puts tell(Other.new, RuntimeError.new("e2"), s)

# another keyword runs code that rewrites the variable before the arm binds it
def swap(who, error)
  src = +"first"
  who.report(error, context: (src = +"second"; {}), source: src)
  src
end
puts swap(Marker.new, RuntimeError.new("e3"))
puts swap(Sub.new, RuntimeError.new("e4"))

# a value that is no variable gets its handle where it runs, rooted beside the
# allocating default of the keyword hash the arm builds (SPINEL_GC_STRESS)
class Marked
  def report(error, context: {}, source: "x")
    source << "!"
    puts "marked #{error} #{source}"
  end
end

class Unmarked
  def report(error, context: {}, source: "x")
    puts "unmarked #{error} #{source}"
  end
end

def dyn(who, error, i)
  who.report(error, source: "n" + i.to_s)
end

dyn(Marked.new, "f", 1)
dyn(Unmarked.new, "g", 2)
