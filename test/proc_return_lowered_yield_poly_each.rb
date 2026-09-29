# A `return` from a block given to a poly receiver's #each, inside a method
# that also yields (so it is lowered to take its block as a proc), returns
# from that method; the block's proc returned the value as a C return and
# the build failed.
class Bag
  def initialize(*a) = @a = a
  def each(&b) = @a.each(&b)
end
class Op
  def self.flat_find object, &block
    if object.respond_to? :each
      object.each do |x|
        result = flat_find x, &block
        return result unless result.nil?
      end
    elsif yield object
      return object
    end
    nil
  end
end
p Op.flat_find([1, [2, "a"], {k: 3}]) { |v| v.is_a?(String) }
p Op.flat_find(Bag.new(1, Bag.new(9, "z"))) { |v| v.is_a?(String) }
p Op.flat_find(5) { |v| false }
