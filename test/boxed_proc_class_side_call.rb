# A boxed Proc or Method beside a class whose class side has `[]` or `call`
# that the boxed call does not reach. A class method nothing calls has no
# arm in the class-value dispatch, so the Proc or the Method is called as
# with no such class; and a `class << self` accessor named `call` is read
# for the class value, while the Proc beside it is called.

class Unused
  def self.[](k = :first) = "unused #{k}"
  def self.call = "unused"
end
def nine = 9
us = [-> { 8 }, method(:nine)]
p us[0][], us[0].call, us[1][], us[1].call

class Svc
  class << self
    attr_accessor :call
  end
end
Svc.call = 3
vals = [Svc, -> { 5 }, method(:nine)]
vals.each { |v| p v.call }
