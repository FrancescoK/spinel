# A method with a rescue declares its locals volatile (they live across the
# setjmp). Lending such a String local to a method that appends to it passed
# `const char *volatile *` where the callee takes `const char **`, which the
# C compiler refused.

def put(data)
  data << "x"
end

def fwd(d) = put(d)

def store
  data = "abc".dup
  put(data)
  [1, 2].each { put(data) }
  fwd(data)
  p data
rescue ArgumentError
  p :err
end

def store_then_raise
  s = "k".dup
  put(s)
  raise ArgumentError
rescue ArgumentError
  p s
end

class Img
  def initialize
    @data = "ab".b
  end

  def store(tracks)
    data = @data.dup
    tracks.each do |entry, bytes|
      next unless entry < 3

      put(data, bytes)
    end
    @data = data
    p @data
  rescue SystemCallError
    p :err
  end

  def put(data, bytes)
    data << bytes
  end
end

store
store_then_raise
Img.new.store({1 => "x", 2 => "yz", 5 => "no"})
