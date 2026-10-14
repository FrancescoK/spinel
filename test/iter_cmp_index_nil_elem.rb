# index / rindex with a block and the comparator blocks (min, max, sort,
# sort!) over an Integer or Float Array holding a nil element see that
# element as nil, whether the block parameter is the element's own slot or
# one widened to poly by another block of the same name.
a = [3, 1]
a[3] = 2
p a.index { |v| v.nil? }
p a.rindex { |v| v.nil? }
p a.max { |x, y| (x || -1) <=> (y || -1) }
p a.min { |x, y| (x || -1) <=> (y || -1) }
p a.min { |x, y| (x || 9) <=> (y || 9) }
p a.sort { |x, y| (x || -1) <=> (y || -1) }
begin
  p a.max { |x, y| x <=> y }
rescue ArgumentError => e
  puts e.message
end

f = [3.5, 1.5]
f[3] = 2.5
p f.index { |v| v.nil? }
p f.rindex { |v| v.nil? }
p f.max { |x, y| (x || -1) <=> (y || -1) }
p f.min { |x, y| (x || -1) <=> (y || -1) }
p f.sort { |x, y| (x || -1) <=> (y || -1) }

class Box
  def bytes
  end

  def floats
  end
end

class Text
  def floats
    a = [1.5]
    a[2] = 2.5
    a
  end
end

Spec = Struct.new(:includes)

def ints_of(pattern)
  a = pattern.bytes
  a[3] = 1
  p a.index { |v| v.nil? }
  p a.rindex { |v| v.nil? }
  p a.max { |x, y| (x || -1) <=> (y || -1) }
  p a.min { |x, y| (x || -1) <=> (y || -1) }
  p a.sort { |x, y| (x || -1) <=> (y || -1) }
  p a.minmax { |x, y| (x || -1) <=> (y || -1) }
  p a.max(2) { |x, y| (x || -1) <=> (y || -1) }
  b = a.dup
  b.sort! { |x, y| (x || -1) <=> (y || -1) }
  p b
end

def floats_of(text)
  a = text.floats
  p a.index { |v| v.nil? }
  p a.rindex { |v| v.nil? }
  p a.max { |x, y| (x || -1) <=> (y || -1) }
  p a.min { |x, y| (x || -1) <=> (y || -1) }
  p a.sort { |x, y| (x || -1) <=> (y || -1) }
end

def walk(patterns)
  patterns.each { |pattern| ints_of(pattern) }
end

def sweep(specs)
  specs.each { |spec| walk(spec.includes) }
end

def build
  Spec.new(["a/b"])
end

ints_of("ab")
floats_of(Text.new)
