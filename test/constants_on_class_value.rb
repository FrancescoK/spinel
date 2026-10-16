# Module#constants on a class or module held in a value -- a parameter, a
# local, an ivar, a boxed value read out of an Array -- lists that class's constants, as on a constant receiver:
# a switch on the class id over the program's classes and modules. console
# registers its formatters this way (`namespace.constants.each` with
# `namespace = Console::Terminal::Formatter`, output/terminal.rb).
module Mixin
  M1 = 1
end
class Base
  B1 = 1
end
class Kid < Base
  include Mixin
  K1 = 2
end
module Empty; end
class Holder
  def initialize(k) = @k = k
  def list = @k.constants.sort
end
def all(k) = k.constants.sort
def own(k) = k.constants(false).sort
p all(Base), all(Kid), all(Empty), all(Mixin)
p own(Kid), own(Base)
p Holder.new(Kid).list
def pick(i) = [Base, Kid, Empty, Mixin][i]
p pick(1).constants.sort, pick(2).constants
k = Kid
p k.constants.sort
def try(k)
  k.constants
rescue NotImplementedError => e
  e.message
end
p try(Kid).sort

module Formatter
  class Failure
    KEY = :failure
    def initialize(t) = @t = t
    def name = "F(#{@t})"
  end
  class Progress
    KEY = :progress
    def initialize(t) = @t = t
    def name = "P(#{@t})"
  end
end
class Output
  def initialize = @formatters = {}
  def register(namespace = Formatter)
    namespace.constants.sort.each do |name|
      formatter = namespace.const_get(name)
      @formatters[formatter::KEY] = formatter.new("t")
    end
    @formatters.map { |k, v| [k, v.name] }
  end
end
p Output.new.register
