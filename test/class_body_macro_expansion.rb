# Class-body macro calls: a module the class extends builds names and code
# from the call's literal arguments (public_send, const_set and module_eval'd
# templates with computed names); the compiler expands them where it can.
module Wrappers
  def wrapper(name, target, args)
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
    def self.#{name}(*a)
      r = #{target}(*a)
      [#{args.inspect}, r]
    end
    RUBY
  end

  # a trailing comment in a template line cuts only itself
  def noted(name, target)
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
    def self.#{name}(*a) = #{target}(*a) # forwards
    RUBY
  end
end

class Calc
  extend Wrappers
  def self.add(a, b) = a + b
  wrapper :plus, :add,
          %i[int int]
  noted :plus2, :add
end
p Calc.plus(2, 3)
p Calc.plus2(4, 5)

# const_set and public_send with a name built from the arguments, keywords
# and defaults, and a macro calling another of its module's macros
module Sizes
  def fn_name(c) = ["calc", "box", c.to_s.downcase].compact.join("_")
  def constant(c, name: c, fallback: nil)
    const_set(name, public_send(fn_name(c)))
  end
end

class Sized
  extend Sizes
  def self.calc_box_size = 32
  def self.calc_box_nonce = 24
  constant :SIZE
  constant :NONCE, name: :NONCE_BYTES
  def self.info = [SIZE, NONCE_BYTES]
end
p Sized.info

# macro calls in the branches of an if, and under a modifier
class Branched
  extend Sizes
  def self.calc_box_size = 1
  def self.calc_box_a = 2
  def self.calc_box_b = 3
  if RUBY_VERSION >= "3"
    constant :A
  else
    constant :B
  end
  constant :SIZE if RUBY_VERSION >= "3" &&
                    RUBY_VERSION < "9"
end
p Branched::A, Branched::SIZE, __LINE__

# two modules with the same last name in different namespaces: each class
# extends the one its constant names
module Left
  module Macros
    def left_size(c) = const_set(c, public_send("left_#{c.to_s.downcase}"))
  end
end
module Right
  module Macros
    def right_size(c) = const_set(c, public_send("right_#{c.to_s.downcase}"))
  end
end
class Lefty
  extend Left::Macros
  def self.left_x = 10
  left_size :X
end
class Righty
  extend Right::Macros
  def self.right_x = 20
  right_size :X
end
p Lefty::X, Righty::X

# a define_singleton_method lambda runs when it is called, on its own self;
# only the macro's locals are substituted into it
module Lambdas
  def reader(name, prefix) = define_singleton_method(name, -> { prefix.to_s + name.to_s.upcase })
end
class Lam
  extend Lambdas
  reader :k, "got-"
end
p Lam.k

# a block parameter named like a macro local is the block's own
module Shadow
  def listed(fn)
    (1..2).each { |fn| puts fn }
    const_set(:LISTED, fn)
  end
end
class Shadowed
  extend Shadow
  listed :z
end
p Shadowed::LISTED

# instance_eval of a string defines on the singleton class, not in the body
module Classy
  def classy(n) = instance_eval("def #{n}; 1; end")
end
class ClassyBox
  extend Classy
  classy :k
end
begin
  p ClassyBox.new.k
rescue NoMethodError
  puts "NoMethodError"
end
