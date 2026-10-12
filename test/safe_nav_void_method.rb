# `x&.m(args)` where m answers nothing (ends in `nil`) and the arguments are
# hoisted ahead of the guard: the `&.` runs the call as a statement and
# answers nil, as a case/if/ternary arm, a method's tail, a local's value,
# a case whose value is used, and a plain statement.
class Card
  def initialize = @regs = Array.new(4, 0)
  def poke(addr, value)
    @regs[addr & 3] = value
    nil
  end
  def peek(addr) = @regs[addr & 3]
end

class Page
  def initialize(card) = @card = card

  def case_arm(addr, value)
    case addr
    when 1, 2 then @card&.poke(addr, value)
    when 3 then nil
    end
  end

  def case_value(addr, value)
    x = case addr
        when 1, 2 then @card&.poke(addr, value)
        end
    x
  end

  def if_arm(addr, value)
    if addr > 0
      @card&.poke(addr, value)
    else
      nil
    end
  end

  def ternary(addr, value)
    addr > 0 ? @card&.poke(addr, value) : nil
  end

  def tail(addr, value)
    @card&.poke(addr, value)
  end

  def local(addr, value)
    r = @card&.poke(addr, value)
    r
  end

  def stmt(addr, value)
    @card&.poke(addr, value)
    addr
  end

  def card = @card
end

a = Page.new(Card.new)
b = Page.new(nil)
[a, b].each do |pg|
  p pg.case_arm(1, 5)
  p pg.case_value(2, 6)
  p pg.if_arm(3, 7)
  p pg.ternary(0, 8)
  p pg.tail(1, 9)
  p pg.local(2, 10)
  p pg.stmt(3, 11)
end
p a.card.peek(1)
p a.card.peek(2)
p a.card.peek(3)
p b.card
