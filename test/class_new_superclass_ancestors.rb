# spinel: share
# spinel: gc-minor
# Class.new(X) keeps the TypeError for a module when the module comes first in
# the lookup of the namespace it is written in: through `include A, B` (A is
# searched first), a later reopening that includes it, a superclass of the class
# or a prepended module, ahead of the top-level class of that name.
module A1; module X; end; end
module B1; class X; def hi = :b1; end; end
class C1
  include A1, B1
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "C1 #{e.message}"
  end
end

module A3; class X; def hi = :a3; end; end
module B3; module X; end; end
class C3; include A3; end
class C3
  include B3
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "C3 #{e.message}"
  end
end

class S4; class X; def hi = :s4; end; end
module M4; module X; end; end
class C4 < S4; end
class C4
  include M4
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "C4 #{e.message}"
  end
end

module P8; module X; end; end
class X; def hi = :top; end
class C8
  prepend P8
  begin
    K = Class.new(X)
    p K.superclass
  rescue TypeError => e
    puts "C8 #{e.message}"
  end
end

