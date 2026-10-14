# `alias_method` in `class << self` names a class method. An instance method
# of the alias's new name, defined later, ended it, so `M.snake` was refused
# (#9177; raylib-bindings has every function both ways). And an alias of a
# class method the class redefines later keeps the body it captured, as an
# instance alias does: it answered the redefinition.
module N
  def self.Camel(x)
    1
  end

  class << self
    alias_method :snake, :Camel
  end
end

module M
  def self.Camel(x)
    1
  end

  class << self
    alias_method :snake, :Camel
  end

  def snake(x)
    2
  end
end

puts "N=#{N.snake(3)}"
puts "M=#{M.snake(3)}"

class User
  include M

  def run = snake(0)
end
p User.new.run

class K
  def self.a = 1

  class << self
    alias_method :b, :a
  end

  def self.a = 2
  def b = 3
end
p K.b, K.a, K.new.b
