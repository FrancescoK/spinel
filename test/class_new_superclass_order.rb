# spinel: share
# spinel: gc-minor
# Class.new(X) sees only what exists when it runs, from the scopes Ruby searches:
# an include that comes after the call is no ancestor yet, a class defined after
# the call is not found, and `class A::B` does not search A.
module A9; class X; def hi = :a9; end; end
module X; end
class C9
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "C9 #{e.message}"
  end
  include A9
end

module A12; class X; def hi = :a12; end; class B; end; end
module X; end
class A12::B
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "B #{e.message}"
  end
end

module X; end
module O16
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "O16 #{e.message}"
  end
  class X; def hi = :o16; end
end

