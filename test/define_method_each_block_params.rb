# `%w(...).each { |m| define_method("#{m}!") { |*args| ... } }` defines one
# method per name, taking the block's parameters: activesupport's
# Multibyte::Chars defines reverse! and tidy_bytes! this way. The unrolled
# methods were given no parameters, so `args` in their bodies was never
# declared and the C did not compile.
class Chars
  def initialize(s) = @s = s
  def reverse = Chars.new(@s.reverse)
  def upcase(*opts) = Chars.new(@s.upcase(*opts))
  def pad(width, fill = "*") = Chars.new(@s.center(width, fill))
  def to_s = @s

  %w(reverse upcase).each do |method|
    define_method("#{method}!") do |*args|
      @s = public_send(method, *args).to_s
      self
    end
  end

  %w(pad).each do |method|
    define_method("#{method}!") do |width, fill = "-"|
      @s = public_send(method, width, fill).to_s
      self
    end
  end
end

c = Chars.new("abc")
p c.reverse!.to_s
p c.upcase!.to_s
p c.upcase!(:ascii).to_s
p c.pad!(7).to_s
p c.pad!(9, "+").to_s
