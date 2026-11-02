class Foo__Mutex
  def w = :plain
end
module Foo
  class Mutex
    def w = :nested
  end
end
p Foo__Mutex.new.w
p Foo::Mutex.new.w
