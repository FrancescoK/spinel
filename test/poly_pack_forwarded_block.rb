# a class whose own pack forwards to its Array's, handing on its block:
# the Array's pack, reached through the dispatch the class's pack opens,
# answers its String

class C
  def initialize(a) = (@a = a)
  def to_a = @a
  def pack(*args, &blk)
    case args.size
    when 1 then to_a.pack(args[0], &blk)
    else raise ArgumentError
    end
  end
end
C.new([1, :x])
p C.new([65, 66]).pack("C*")
p C.new([67]).pack("C")
