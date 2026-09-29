# A program class whose leaf name is a native class's declared under a
# qualified path -- `Ring::Buffer` beside the runtime's IO::Buffer -- is its
# own class: it is path-qualified the way two sibling namespaces' same-named
# classes are, so the leaf-keyed lookup keeps the two apart. It used to be
# refused ("rename the class"), which activesupport's Cache::Store hit
# beside OpenSSL::X509::Store.
module Ring
  class Buffer
    def initialize(n) = @slots = Array.new(n, 0)
    def size = @slots.size
    def put(i, v)
      @slots[i % size] = v
      self
    end
    def to_a = @slots
  end
end
r = Ring::Buffer.new(3).put(4, 9)
p r.size, r.to_a, r.class == Ring::Buffer
b = IO::Buffer.new(8)
p b.size, b.class == IO::Buffer, Ring::Buffer == IO::Buffer
