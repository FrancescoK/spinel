# private / protected in a `class << Foo` outside Foo's body make Foo's class
# methods private / protected, as they do in a `class << self` inside it.

class Bar
  def self.h = 1
  def self.k = 2
  def self.call_h = h
end
class << Bar
  private :h
  def pv = 3
  def pub = pv
  private :pv
  protected def prot = 4
  attr_accessor :conf
  private :conf=
end
p Bar.respond_to?(:h), Bar.respond_to?(:k), Bar.call_h, Bar.pub, Bar.respond_to?(:pv)
p Bar.respond_to?(:conf), Bar.respond_to?(:conf=)
begin
  Bar.h
rescue NoMethodError => e
  puts e.message
end
module Util; end
class << Util
  def helper = :ok
  private :helper
  def run = helper
end
p Util.run, Util.respond_to?(:helper)
