# A `**` forward into a class-value `.new` doesn't inline another class's
# keyword default (one reading an earlier parameter) into the caller.
class Tune
  def model = :m6581
end

class Player
  def initialize(tune, model: tune.model)
    @model = model
  end

  def model = @model
end

class MapA
  def initialize(crt, **) = (@crt = crt)
  def crt = @crt
end

class MapB
  def initialize(crt, **) = (@crt = crt)
  def crt = @crt
end

def build_anon(crt, **)
  mapper = crt == 1 ? MapA : MapB
  mapper.new(crt, **)
end

def build_named(crt, **opts)
  mapper = crt == 1 ? MapA : MapB
  mapper.new(crt, **opts)
end

p Player.new(Tune.new).model
p build_anon(1, x: 2).crt
p build_named(2, x: 2).crt
