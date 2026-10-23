# A builder chain whose arguments are calls with blocks the callee keeps.
# Each link's receiver and argument are both calls, so each link binds them
# to temps ahead of the call; the call took its operands back whenever it
# held them a second time, and re-emitted them -- blocks included -- with
# the whole call, once per enclosing link: 2^depth copies of each block's
# function (16 links wrote 364 MB of C). Every link is emitted once, and
# each block runs once.
class E
  attr_reader :tag

  def initialize(tag)
    @tag = tag
    @kids = []
  end

  def child(e)
    @kids << e
    self
  end

  def on_click(&b)
    @handler = b
    self
  end

  def click = @handler.call
  def tags = @kids.map(&:tag)
  def total = @kids.sum(&:click)
end

root = E.new(0)
  .child(E.new(1).on_click { 1 })
  .child(E.new(2).on_click { 2 })
  .child(E.new(3).on_click { 3 })
  .child(E.new(4).on_click { 4 })
  .child(E.new(5).on_click { 5 })
  .child(E.new(6).on_click { 6 })
  .child(E.new(7).on_click { 7 })
  .child(E.new(8).on_click { 8 })
  .child(E.new(9).on_click { 9 })
  .child(E.new(10).on_click { 10 })
  .child(E.new(11).on_click { 11 })
  .child(E.new(12).on_click { 12 })
  .child(E.new(13).on_click { 13 })
  .child(E.new(14).on_click { 14 })
  .child(E.new(15).on_click { 15 })
  .child(E.new(16).on_click { 16 })
p root.tags
p root.total
