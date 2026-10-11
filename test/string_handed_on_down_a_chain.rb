# A String handed four methods down, through parameters that also take
# other values: none of them appends, so the caller's String goes over
# as it is.
class Resolver
  def initialize
    @seen = {}
  end

  def resolve(name)
    return @seen[name] if @seen.include?(name)
    @seen[name] = lookup(name)
  end

  def lookup(name)
    find(name) || name.size
  end

  def find(name)
    name.start_with?("R") ? name.upcase : nil
  end
end

class Linker
  def initialize
    @resolver = Resolver.new
  end

  def link(name, text)
    ref = @resolver.resolve(name)
    "#{text}:#{ref}"
  end

  def cross_reference(name, text = nil)
    text ||= name
    link(name, text)
  end

  def handle(url)
    if url =~ /\Aref:/
      ref = $'
      cross_reference(ref)
    end
  end
end

l = Linker.new
p l.handle("ref:Rdoc")
p l.handle("ref:other")
p l.cross_reference(:sym)

# The same chain, where the last method appends: the append is the caller's.
class Marker
  def note(name) = tag(name)
  def tag(name) = mark(name)
  def mark(name) = stamp(name)

  def stamp(name)
    name << "!" if name.is_a?(String)
    name
  end
end

def mark_ref(url)
  ref = url[4..]
  Marker.new.note(ref)
  ref
end

p mark_ref("ref:Rdoc")
p Marker.new.note(:sym)

# Hand-ons that come back around: the walk ends, and finds no append.
def ping(s, n)
  return s.size if n == 0
  pong(s, n - 1)
end

def pong(s, n)
  pang(s, n)
end

def pang(s, n)
  ping(s, n)
end

w = +"word"
p ping(w, 5)
p ping([1, 2], 3)
p w
