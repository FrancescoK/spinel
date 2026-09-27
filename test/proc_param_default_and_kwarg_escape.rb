class Playback
  def initialize(sleeper: ->(seconds) { p(seconds) })
    @sleeper = sleeper
  end

  def wait(ahead)
    @sleeper.call(ahead / 2)
  end
end

Playback.new.wait(0.15)
Playback.new(sleeper: ->(seconds) { p(seconds * 2) }).wait(0.15)

class Positional
  def initialize(sleeper = proc { |s| p(s) })
    @sleeper = sleeper
  end

  def wait(a)
    @sleeper.(a / 2)
    @sleeper[a / 4]
  end
end

Positional.new.wait(0.5)

def label(f: ->(s) { p(s) })
  f.call("str")
end

label
label(f: ->(s) { p(s + "!") })

def opt(f = ->(s) { p(s) })
  f.call(1.25)
end

opt
