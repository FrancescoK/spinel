# `K.include(M)`, `K.prepend(M)` and `K.send(:include, M)` as statements of
# the program, K a builtin class: the reopening `class K; include M; end`
# they amount to. A prepended module reaches the builtin through super.
module Shout
  def upcase = "!" + super
end

module Flag
  def flag? = true
end

module Maybe
  def maybe? = nil
end

module Twice
  def twice = self * 2
end

String.prepend(Shout)
Integer.include(Flag)
Float.send(:include, Flag)
Array.__send__(:include, Flag)
NilClass.public_send(:include, Flag)
Symbol.include Flag
Numeric.prepend(Twice)
Object.send(:include, Maybe)

p "ab".upcase
s = ["xy", 1][0]
p s.upcase
p ["q", "r"].map(&:upcase)
p String.ancestors.first(2)
p 1.flag?, 2.5.flag?, [].flag?, nil.flag?, :a.flag?
p [1, 2].map(&:flag?)
p 3.twice, 1.5.twice
p 1.maybe?, "s".maybe?, Object.new.maybe?
p Integer.include?(Flag), Integer.ancestors.include?(Flag)

# a class or module of the program through send, and its singleton class
module Tagged
  def tag = "tag"
end

module Greeting
  def hello = "hello " + super
end

class Box
  def self.hello = "box"
end

module Config
  def self.hello = "config"
end

Box.send(:include, Tagged)
Box.singleton_class.prepend(Greeting)
Config.singleton_class.prepend Greeting
p Box.new.tag, Box.hello, Config.hello
