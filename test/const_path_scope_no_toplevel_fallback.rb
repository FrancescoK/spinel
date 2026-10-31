# A scoped constant path does not fall back to a top-level constant: a
# class or module scope holds only its own members (and its ancestors'),
# so Holder::Target raises NameError though Target is defined at the top
# level. Object::Target is the top-level one (#10577).
class Holder; end
class Target
  def self.v = 9
end
module Mod; end
class Base
  class Inner
    def self.v = 1
  end
end
class Sub < Base; end

begin
  p Holder::Target.v
rescue NameError => e
  puts "NameError: #{e.message}"
end
begin
  p Mod::Target.v
rescue NameError => e
  puts "NameError: #{e.message}"
end
begin
  x = Holder::Target
  p x
rescue NameError => e
  puts "NameError: #{e.message}"
end
begin
  p Holder::Target.new
rescue NameError => e
  puts "NameError: #{e.message}"
end
p defined?(Holder::Target)
p Object::Target.v
p Sub::Inner.v
p Base::Inner
