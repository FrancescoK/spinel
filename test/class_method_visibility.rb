class Single
  private_class_method :new
  def self.instance = (@inst ||= new)
  def hi = "hi"
end
p Single.instance.hi
begin
  Single.new
rescue NoMethodError => e
  puts e.message
end

class Base
  def self.a = 1
  def self.b = 2
  def self.c = 3
  private_class_method :a, :b
  private_class_method def self.d = 4
  public_class_method :b
  def self.sum = a + b + c + d + self.a
end
p Base.sum, Base.b, Base.c
class Kid < Base
  def self.kid_sum = a + d
end
p Kid.kid_sum
begin; Kid.a; rescue NoMethodError => e; puts e.message; end
begin; Base.d; rescue NoMethodError => e; puts e.message; end
k = Base
begin; k.a; rescue NoMethodError => e; puts e.message; end
p Base.send(:a)
begin; Base.public_send(:d); rescue NoMethodError => e; puts e.message; end

class Cfg
  class << self
    attr_accessor :level
    private
    attr_writer :secret
    def helper(x) = x * 2
    public
    def run = helper(3)
  end
  def inst = self.class.run
end
p Cfg.run, Cfg.new.inst
Cfg.level = 4
p Cfg.level
begin; Cfg.helper(1); rescue NoMethodError => e; puts e.message; end
begin; Cfg.secret = 1; rescue NoMethodError => e; puts e.message; end

class Priv
  private
  def self.still_public = 5
end
p Priv.still_public
module Util
  class << self
    private
    def inner = 7
  end
  def self.outer = inner
end
p Util.outer
begin; Util.inner; rescue NoMethodError => e; puts e.message; end
p Base.respond_to?(:a), Base.respond_to?(:c)
p Base.respond_to?(:a, true), Util.respond_to?(:inner), Single.respond_to?(:new)
class Base
  def self.probe = [respond_to?(:a), respond_to?(:a, true), respond_to?(:c)]
end
p Base.probe
module M
  def self.q = 1
  private_class_method :q
end
begin; M.q; rescue NoMethodError => e; puts e.message; end
class E
  class << self
    protected
    def pz = 1
    public
    def ok = E.pz
  end
  def i = E.pz
end
p E.ok
begin; E.new.i; rescue NoMethodError => e; puts e.message; end
