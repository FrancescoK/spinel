# A class-value `k.new(x, **)` whose reachable initializers have a keyword
# default reading an earlier parameter: the default is evaluated with that
# parameter bound, as a call to the initialize would. A local holding one of
# a known set of classes constructs just those.

class Tune
  def model = 6581
end

class Solo
  def initialize(tune, song: nil, model: tune.model)
    @model = model
    @song = song
  end

  def to_s = "Solo #{@model} #{@song.inspect}"
end

class Duo
  def initialize(tune, song: nil, model: tune.model)
    @model = model + 1
    @song = song
  end

  def to_s = "Duo #{@model} #{@song.inspect}"
end

class Pair
  def initialize(a:, b: a + 1)
    @v = [a, b]
  end

  def to_s = "Pair #{@v.inspect}"
end

class Trio
  def initialize(a:, b: a * 3)
    @v = [a, b]
  end

  def to_s = "Trio #{@v.inspect}"
end

class M1
  def initialize(crt, flag: false)
    @crt = crt
    @flag = flag
  end

  def to_s = "M1 #{@crt} #{@flag}"
end

class M2
  def initialize(crt, flag: false)
    @crt = crt
    @flag = flag
  end

  def to_s = "M2 #{@crt} #{@flag}"
end

PLAYERS = { solo: Solo, duo: Duo }.freeze

def build(crt, **)
  mapper = crt == 1 ? M1 : M2
  mapper.new(crt, **)
end

def player(kind, tune, **) = PLAYERS.fetch(kind).new(tune, **)

puts build(1, flag: true)
puts build(2)
puts player(:solo, Tune.new)
puts player(:duo, Tune.new, song: 3)
puts player(:solo, Tune.new, model: 8580)
puts (ARGV.empty? ? Solo : Duo).new(Tune.new, song: 1)
opts = { song: 2 }
puts (ARGV.empty? ? Duo : Solo).new(Tune.new, **opts)

pk = ARGV.empty? ? Pair : Trio
puts pk.new(**{ a: 1 })
puts pk.new(**{ a: 1, b: 5 })
tk = ARGV.empty? ? Trio : Pair
kw = { a: 4 }
puts tk.new(**kw)

# a default's own statements run only when the hash leaves its key out
def note(n)
  puts "note #{n}"
  n * 2
end

class Noted
  def initialize(a:, b: [note(a), a].max, c: begin; note(a + 1); rescue; 0; end)
    @v = [a, b, c]
  end

  def to_s = "Noted #{@v.inspect}"
end

def noted(**) = Noted.new(**)

puts Noted.new(**{ a: 1, b: 7, c: 8 })
puts Noted.new(**{ a: 1 })
puts noted(a: 2, b: 9, c: 3)
puts noted(a: 2)
