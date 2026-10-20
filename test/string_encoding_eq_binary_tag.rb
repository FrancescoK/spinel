# A typed String's #encoding compared with Encoding::BINARY or UTF_8, the
# String read from a variable, compiles to its binary tag: both operand orders,
# == and !=, the BINARY alias, ::Encoding, a local and an ivar, a String that
# can be nil (nil.encoding raises), and a receiver that is a call (evaluated
# once). `s&.encoding` answers nil for nil, and an Encoding the program nests
# where the comparison is written is its own.
def bin?(s) = s.encoding == Encoding::BINARY
def utf?(s) = Encoding::UTF_8 == s.encoding
def not_bin?(s) = s.encoding != Encoding::ASCII_8BIT
def not_utf?(s) = Encoding::UTF_8 != s.encoding

["abc", "가", "abc".b, "\xff".b, "#{1}x", String.new(encoding: Encoding::BINARY)].each do |s|
  p [bin?(s), utf?(s), not_bin?(s), not_utf?(s)]
end

class Holder
  def initialize(s) = @s = s
  def bin? = @s.encoding == Encoding::BINARY
  def utf? = @s.encoding == Encoding::UTF_8
end
p [Holder.new("a").bin?, Holder.new("a").utf?, Holder.new("a".b).bin?, Holder.new("a".b).utf?]

def maybe(n) = n > 0 ? "x".b : nil
p bin?(maybe(1))
begin
  p bin?(maybe(0))
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
def utf_maybe?(s) = Encoding::UTF_8 == s.encoding
p utf_maybe?(maybe(1))
begin
  p utf_maybe?(maybe(0))
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

$made = 0
def fresh
  $made += 1
  "x".b
end
p [fresh.encoding == Encoding::BINARY, Encoding::UTF_8 == fresh.encoding, $made]

# a constant that is neither still compares as before
p ["a".b.encoding == Encoding::US_ASCII, "a".encoding == Encoding::US_ASCII]

def safe_bin?(s) = s&.encoding == Encoding::BINARY
p [safe_bin?(nil), safe_bin?("x".b), safe_bin?("x")]

def top_bin?(s) = s.encoding == ::Encoding::BINARY
p [top_bin?("x".b), top_bin?("x")]

module Local
  module Encoding
    BINARY = 4
    UTF_8 = 5
  end
  def self.bin?(s) = s.encoding == Encoding::BINARY
  def self.utf?(s) = s.encoding == Encoding::UTF_8
end
p [Local.bin?("x".b), Local.utf?("x")]
