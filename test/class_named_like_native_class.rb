# Each class here is a new class in CRuby, not a reopening of a builtin
# class. A class nested in a module or a class has its own name. A top-level
# name that only contains a builtin name is a different name. CRuby loads
# OpenStruct only after require "ostruct", so here it is a new class.
module App
  class Mutex
    def hi = "app mutex"
  end

  class Queue
    def initialize(name)
      @name = name
    end

    def hi = "app queue #{@name}"
  end
end

class Foo
end

class Foo::Mutex
  def hi = "foo mutex"
end

class Foo__Mutex
  def hi = "foo__mutex"
end

class OpenStruct
  def initialize(name)
    @name = name
  end

  def hi = "my struct #{@name}"
end

puts App::Mutex.new.hi
puts App::Queue.new("a").hi
puts Foo::Mutex.new.hi
puts Foo__Mutex.new.hi
puts OpenStruct.new("b").hi
m = Mutex.new
m.synchronize { puts "builtin mutex" }
