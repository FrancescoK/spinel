class Base
  def initialize(a, b, c, d = {})
    @a = a
    @b = b
    @c = c
    if d.empty?
      @d = nil
    else
      @d = d
    end
  end
  def show
    p [@a, @b, @c, @d]
  end
end

class Select < Base
  def initialize(a, b, c, choices, options, html)
    @choices = block_given? ? yield : choices
    @html = html
    super(a, b, c, options)
  end
  def show
    super
    p [@choices, @html]
  end
end

klass = [Select, Base].first
klass.new(1, 2, 3, 4, { x: 5 }, 6).show
klass.new(1, 2, 3, 4, {}, 6) { 7 }.show
Select.new(1, 2, 3, 4, {}, 6) { 8 }.show
