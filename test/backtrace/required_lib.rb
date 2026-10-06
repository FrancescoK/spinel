class Lib
  def inner(x)
    raise ArgumentError, "bad #{x}" if x > 1
    x
  end

  def boom(x)
    inner(x) + 1
  end

  def self.go(x)
    new.boom(x)
  end
end

def lib_inner(x)
  raise ArgumentError, "bad #{x}" if x > 1
  x
end

def lib_outer(x)
  lib_inner(x) + 1
end
