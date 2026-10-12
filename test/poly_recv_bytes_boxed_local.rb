# A poly receiver's bytes / codepoints / chars assigned to a local that is
# boxed because another class also defines the name. That class is never
# instantiated, so the call compiled to the bare String array, which a poly
# slot cannot hold: the C failed to build.
class Box
  def bytes
  end

  def codepoints
  end

  def chars
  end
end

Spec = Struct.new(:includes)

def split(text)
  a = text.bytes
  b = text.codepoints
  c = text.chars
  p a, b, c
  p a.size + b.size + c.size
end

def walk(texts)
  texts.each { |text| split(text) }
end

def sweep(specs)
  specs.each { |spec| walk(spec.includes) }
end

split("ab")
split("héllo")
