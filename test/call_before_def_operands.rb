# A call before its method's def raises after its operands run, in source
# order: its arguments (an Array's or a Hash's elements too), then its
# block argument, whose conversion to a block can raise first, also where
# the arguments are bound to temporaries ahead of the block's. The error
# carries its receiver and arguments. A constant whose value holds such a
# call runs the operands ahead of it in order. A builtin method answers
# only on a self that has it: Module has no superclass, main no name.
class U
  def self.mark(x)
    puts "mark #{x}"
    x
  end
  def self.s3(a, b, c) = c

  begin
    missing(mark(1), [mark(2)], {a: mark(3)})
  rescue NoMethodError => e
    puts e.message
    p e.receiver, e.args
  end
  begin
    missing(4, &(puts("block"); nil))
  rescue NoMethodError => e
    puts e.message
  end
  begin
    missing(mark(11), &(puts("block3"); nil))
  rescue NoMethodError => e
    puts e.message
  end
  begin
    missing(5, &(1 > 0))
  rescue TypeError => e
    puts e.message
  end
  begin
    zz
  rescue NameError => e
    p e.name, e.receiver
  end

  begin
    A = s3(mark(6), [mark(7)].size, zz)
  rescue NameError => e
    puts e.message
  end
  begin
    B = s3(mark(8), [mark(9), mark(10)].map { |x| x + 1 }, zz)
  rescue NameError => e
    puts e.message
  end

  def self.missing(*a) = 9
  def self.zz = 5
  p missing(mark(12), &(puts("block4"); nil))
end

module M
  begin
    p M.superclass
  rescue NoMethodError => e
    puts e.message
  end
  begin
    p M.allocate
  rescue NoMethodError => e
    puts e.message
  end
  p M.name
  def self.superclass = 7
  def self.allocate = 8
end

begin
  early(1, 2)
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  p self.name
rescue NoMethodError => e
  puts e.message
end
p self.to_s
def early(a, b) = a + b
def name = "nm"
