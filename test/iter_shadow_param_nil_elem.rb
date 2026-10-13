# A block parameter whose slot widened to poly (a second class defining the
# receiver's method name, plus a never-called caller chain) still sees a nil
# element of an Integer or Float array as nil in the typed loops that shadow
# it with the element's type (map, select, reject, inject, sum, sort_by,
# uniq, ...) or bind it boxed (map.with_index, each_with_index.map).
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
  p a.map { |v| v }
  p a.select { |v| v.nil? }
  p a.filter { |v| v.nil? }
  p a.reject { |v| v.nil? }
  p a.inject(0) { |s, v| v.nil? ? s + 100 : s + v }
  p a.sum { |v| v.nil? ? 100 : v }
  p a.sort_by { |v| v.nil? ? -1 : v }
  p a.min_by(2) { |v| v.nil? ? -1 : v }
  p a.uniq { |v| v }
  p a.each_with_index.map { |v, i| [v, i] }
  p a.map.with_index { |v, i| [v, i] }
  p a.each_with_index.select { |v, i| v.nil? }
  u = a.dup
  p u.uniq! { |v| v }
  p u
  p a.slice_when { |x, y| y.nil? || x.nil? }.to_a
  p a.chunk_while { |x, y| !y.nil? && !x.nil? }.to_a
  b = a.dup
  p b.delete_if { |v| v.nil? }
  b = a.dup
  p b.reject! { |v| v.nil? }
end

def floats_of(text)
  a = text.floats
  p a.map { |v| v }
  p a.select { |v| v.nil? }
  p a.each_with_index.select { |v, i| v.nil? }
  p a.uniq { |v| v }
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
