# A builtin's qualified value constant in `when` (Socket::AF_INET,
# File::SEPARATOR, Float::INFINITY) is an equality test, as CRuby's ===
# on an Integer, a String or a Float is; it was taken for a class name and
# the arm folded to false. ipaddr dispatches on its family this way.
require "socket"

def family(f)
  case f
  when Socket::AF_INET then :v4
  when Socket::AF_INET6 then :v6
  else :other
  end
end

p family(Socket::AF_INET)
p family(Socket::AF_INET6)
p family(nil)
p family(-1)

def sep(s)
  case s
  when File::SEPARATOR then :sep
  else :no
  end
end

p sep("/"), sep("x")

def inf(x)
  case x
  when Float::INFINITY then :inf
  when 1.5 then :one_half
  else :finite
  end
end

p inf(1.0 / 0), inf(1.5), inf(2.0)
