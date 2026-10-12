# A block parameter whose slot widened to poly (a second class defining the
# receiver's method name, plus a never-called caller chain) still iterates an
# Integer or Float array that holds nils. Boxing each element dropped its nil
# bit, so a nil element arrived in the block as 0 or 0.0.
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
  a.each_with_index { |value, i| p [value, i] }
  a.each { |v| p v }
  a.each { |*values| p values }
  a.reverse_each { |v| p v }
  a.take_while { |v| p v; true }
  a.each_slice(2) { |x, y| p [x, y] }
  a.zip(a) { |x, y| p [x, y] }
end

def floats_of(text)
  a = text.floats
  a.each_with_index { |value, i| p [value, i] }
  a.each { |v| p v }
  a.each { |*values| p values }
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
