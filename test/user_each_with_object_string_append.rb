# A user method named `each_with_object` hands its block whatever it likes --
# here a String as the second argument. The builtin memo rule clears the
# block's second-parameter append bit by NAME alone, which dropped this real
# appender, so the program counted no appender and `@blk.call` handed the
# String a copy: the append was lost (CRuby prints "seed!"). The rule now
# applies only to the builtin, and the String is shared, so the append
# reaches the caller's String.
class Box
  def each_with_object(memo, &blk)
    @blk = blk
    run
  end

  def run
    s = String.new("seed")
    @blk.call(1, s)
    s
  end
end

p Box.new.each_with_object({}) { |x, s| s << "!" }
