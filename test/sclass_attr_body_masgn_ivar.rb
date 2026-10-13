# A class << self accessor reads and writes the class-level ivar its class
# body assigns, however the body assigns it: a multiple assignment, a
# nested one, ||= or +=.

class Config
  @title, @limit = "cfg", 10
  class << self
    attr_accessor :title, :limit
  end
end
p Config.title, Config.limit
Config.limit += 5
p Config.limit
class Opts
  (@a, @b), @c = [1, 2], 3
  @d ||= 4
  @e = 0
  @e += 5
  class << self
    attr_reader :a, :b, :c, :d, :e
  end
end
p [Opts.a, Opts.b, Opts.c, Opts.d, Opts.e]
