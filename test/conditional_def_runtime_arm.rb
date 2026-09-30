FLAG = ENV["SPINEL_TEST_NEVER_SET"] == "1"

class Codec
  if FLAG
    def encode(s) = s.upcase
  else
    def encode(s) = s.downcase
  end

  unless FLAG
    def kind = "plain"
  else
    def kind = 42
  end

  def each_part(s)
    s.chars.reverse_each { |ch| yield ch }
  end if FLAG
  def each_part(s)
    s.each_char { |ch| yield ch }
  end unless FLAG

  if FLAG
    def scale(x, factor = 2) = x * factor
  else
    def scale(x, factor = 3) = x * factor + 1
  end

  unless FLAG
    def self.label = "codec"
  else
    def self.label = "fast codec"
  end

  class << self
    unless FLAG
      def level = 1
    else
      def level = 2
    end
  end

  def pick = "base"

  if FLAG
    def only_flag = 1
  elsif ENV["SPINEL_TEST_NEVER_SET"] == "2"
    def only_flag = 2
  end
end

class Codec
  def pick = "reopened" if FLAG
end

module Outer
  class Box
    def m = "outer box"
  end
end

class Outer::Box
  def m = "reopened box" if FLAG
end

unless FLAG
  def helper(a) = a + 1
else
  def helper(a) = a - 1
end

c = Codec.new
p c.encode("MiXed")
p c.kind
parts = []
c.each_part("abc") { |ch| parts << ch }
p parts
p c.scale(5)
p c.scale(5, 10)
p Codec.label
p Codec.level
p c.pick
p Outer::Box.new.m
p helper(10)
begin
  c.only_flag
rescue NoMethodError => e
  p e.message
end
