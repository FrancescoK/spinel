# select.with_index over a receiver known only at run time (a second class
# defining `bytes`, plus a never-called caller chain) binds the element
# boxed, so a nil element of the Integer Array it holds stays nil.
class Box
  def bytes
  end
end

Spec = Struct.new(:includes)

def ints_of(pattern)
  a = pattern.bytes
  a[3] = 1
  p a.select.with_index { |v, i| v.nil? || i == 0 }
  p a.filter.with_index { |v, i| v.nil? }
  p a.reject.with_index { |v, i| v.nil? }
  p a.map.with_index { |v, i| [v, i] }
  p a.filter_map.with_index { |v, i| [v, i] if v.nil? }
  p a.each_with_index.select { |v, i| v.nil? }
  p a.select(&:nil?)
  p a.reject(&:nil?)
  p a.count(&:nil?)
  p a.map(&:to_s)
end

def walk(patterns)
  patterns.each { |pattern| ints_of(pattern) }
end

def sweep(specs)
  specs.each { |spec| walk(spec.includes) }
end

ints_of("ab")
