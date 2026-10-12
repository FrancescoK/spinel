# A module method included into a reopened builtin reaches the builtin's
# class methods through `self.class`, as one written in the reopening does.
module Calculations
  def past? = self < self.class.current
  def future? = self > self.class.current
end

module Defaulting
  def or_default = empty? ? self.class.default : self
end

module Scaling
  def scaled = self * self.class.base
end

class Time
  include Calculations
  def self.current = Time.at(100)
end

class String
  include Defaulting
  def self.default = "default"
end

class Integer
  include Scaling
  def self.base = 10
end

p Time.at(0).past?
p Time.at(200).past?
p Time.at(200).future?
p "".or_default
p "given".or_default
p 3.scaled
