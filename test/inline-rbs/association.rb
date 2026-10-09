# Comment grouping follows ruby/rbs for both leading and trailing blocks.
class Association
  class_eval do
    #: (untyped) -> untyped
    def in_block(x) = x

    attr_reader :block_attr #: String?
  end

  # @rbs @multiline: Integer
  attr_accessor :multiline #: String
                           #   ?

  #: (untyped,
  #
  #   untyped) -> untyped
  def internal_blank(x, y) = x + y

  def block_attr_value = @block_attr

  def initialize
    @block_attr = nil
    @multiline = nil
  end
end

a = Association.new
p a.in_block(1), a.block_attr_value, a.multiline, a.internal_blank(2, 3)
