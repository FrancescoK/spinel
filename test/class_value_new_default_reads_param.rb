# A `.new` dispatched over several classes (a Class value, or a poly one)
# fills an omitted default at the call site. A default reading an earlier
# parameter emitted the constructor's own parameter there, which the caller
# does not declare: the C build failed with `lv_tune` undeclared.

class Tune
  attr_reader :model

  def initialize(model)
    @model = model
  end
end

class Player
  def initialize(tune, song: nil, model: tune.model)
    @song = song
    @model = model
  end

  def show = puts("Player #{@song.inspect} #{@model}")
end

class Doubler
  def initialize(tune, a = tune.model * 2, b = a + 1)
    @a = a
    @b = b
  end

  def show = puts("Doubler #{@a} #{@b}")
end

class Plain
  def initialize(tune)
    @model = tune.model
  end

  def show = puts("Plain #{@model}")
end

class Counter
  def initialize(n = 3, twice = n * 2)
    @n = n
    @twice = twice
  end

  def show = puts("Counter #{@n} #{@twice}")
end

Player.new(Tune.new(6581)).show
Doubler.new(Tune.new(10), 5).show

def build(klass, tune) = klass.new(tune)
build(Player, Tune.new(8580)).show
build(Doubler, Tune.new(10)).show
build(Plain, Tune.new(1)).show

[Player, Doubler, Plain].each { |k| k.new(Tune.new(7)).show }
[Player, Doubler, Plain][ARGV.size].new(Tune.new(9)).show

def count(klass) = klass.new(4)
count(Counter).show
[Counter, Plain].first.new(5).show
