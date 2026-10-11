# A subclass of a Singleton class has its own instance, and an `initialize`
# that reaches another singleton's `instance` builds that one first.
require "singleton"

class Store
  include Singleton

  def initialize
    puts "#{self.class}#initialize"
  end
end

class CacheStore < Store
end

class App
  include Singleton

  attr_reader :store

  def initialize
    @store = Store.instance
    puts "App#initialize"
  end
end

p App.instance.store.equal?(Store.instance)
p CacheStore.instance.equal?(Store.instance)
p CacheStore.instance.class
p CacheStore.instance.equal?(CacheStore.instance)
