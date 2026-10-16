# frozen_string_literal: true
# rb_equal, rb_eql and rb_respond_to answer through the receiver's method.
require_relative 'dispatch'

class Loose
  def ==(other) = true
  def eql?(other) = other.is_a?(Loose)
  def respond_to?(name, include_all = false) = name == :size || super

  private

  def secret = 1
end

nan = Float::NAN
loose = Loose.new
p CextDispatch.equal(1, 1.0), CextDispatch.equal("a", "a"), CextDispatch.equal([1], [2])
p CextDispatch.equal(nan, nan), nan == nan
p CextDispatch.equal(loose, 3), CextDispatch.equal("a", loose)
p CextDispatch.eql(1, 1.0), CextDispatch.eql("a", "a"), CextDispatch.eql(loose, Loose.new)
p CextDispatch.eql(nan, nan), CextDispatch.eql(loose, 3)
p CextDispatch.responds("abc"), CextDispatch.responds(5), CextDispatch.responds(loose)
p CextDispatch.responds_private(loose, false), CextDispatch.responds_private(loose, true)
