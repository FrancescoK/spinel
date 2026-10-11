# Spinel package: singleton
#
# The Singleton module from Ruby's standard library: `include Singleton`
# makes `new` and `allocate` private and gives the class an `instance`
# method that builds its one instance on first use. A subclass gets its
# own instance, and the instance refuses `dup` and `clone`.
#
# CRuby's singleton.rb defines `instance` on each including class from a
# hook; here a module of class methods is extended into the class instead.
# Each class builds its instance under a lock of its own, made on first
# use under a shared lock that is never held across `new`.

module Singleton
  VERSION = "0.3.0"

  module SingletonClassMethods
    def _load(str)
      instance
    end

    def instance
      @singleton__instance__ || begin
        lock = SINGLETON_SETUP_LOCK.synchronize { @singleton__lock__ ||= Thread::Mutex.new }
        lock.synchronize { @singleton__instance__ ||= new }
      end
    end
  end

  SINGLETON_SETUP_LOCK = Thread::Mutex.new
  private_constant :SINGLETON_SETUP_LOCK

  def self.included(klass)
    klass.extend(SingletonClassMethods)
    klass.private_class_method :new, :allocate
  end

  def clone
    raise TypeError, "can't clone instance of singleton #{self.class}"
  end

  def dup
    raise TypeError, "can't dup instance of singleton #{self.class}"
  end

  def _dump(depth = -1)
    ''
  end
end
