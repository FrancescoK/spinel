# A class variable written nil once (its declaration) and by a writer no one
# calls has no typed value; it reads nil, is a falsy condition, and its
# reader answers a value the consumers dispatch on. The slot used to be
# given an Integer global, and a reader used as a condition (or the direct
# `@@x ? a : b`) was refused as a non-bool condition.
module Conf
  @@parse_times = nil
  @@strict = nil
  def self.parse_times = @@parse_times
  def self.parse_times=(v)
    @@parse_times = v
  end
  def self.strict = @@strict
  def self.strict=(v)
    @@strict = v
  end
  def self.direct = @@parse_times ? "on" : "off"

  module JSON
    def self.decode(s) = Conf.parse_times ? s.upcase : s
    def self.tag(s) = Conf.strict ? "strict #{s}" : "loose #{s}"
    def self.both(s) = Conf.parse_times || Conf.strict ? "some" : "none"
  end
end

p Conf::JSON.decode("a")
p Conf::JSON.tag("b")
p Conf::JSON.both("c")
p Conf.parse_times
p Conf.parse_times.nil?
p Conf.direct
puts "off" unless Conf.strict
