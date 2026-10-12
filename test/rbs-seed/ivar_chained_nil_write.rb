# spinel: rbs-seed-run
# Ivars of different seeded kinds cleared in one chained assignment
# (webrick's Cookie#initialize: `@domain = @path = ... = @max_age = nil`).
# Each takes the nil at the bottom of the chain; the contradiction check read
# the value of `@comment = @max_age = nil` as @max_age's seeded Integer and
# refused it for the String @comment.
class ChainNilCookie
  attr_accessor :comment, :max_age, :secure
  def initialize
    @comment = @max_age = @secure = nil
  end
end
c = ChainNilCookie.new
p c.comment, c.max_age, c.secure
c.comment = "x"
c.max_age = 3
c.secure = true
p c.comment, c.max_age, c.secure
