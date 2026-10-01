# A method that answers through the same call on a boxed value: the
# wrapper's to_ary returns @body.to_ary, and @body is an Array or another
# wrapper. Its own answer is not known until it is, so the builtin's (an
# Array's to_ary) types the call, and an Array in @body has an arm.
class Wrapper
  def initialize(body) = (@body = body; @closed = false)

  def to_ary
    @body.to_ary.tap do |content|
      raise "differs" unless content == @body.to_ary
    end
  ensure
    close
  end

  def close = @closed = true
  def closed? = @closed
end

w = Wrapper.new(["a", "b"])
p w.to_ary, w.closed?
p Wrapper.new(Wrapper.new(["c"])).to_ary
p Wrapper.new([1, 2]).to_ary.sum
