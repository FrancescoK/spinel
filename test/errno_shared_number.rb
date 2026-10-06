# Two Errno names that share a number are one class, as in CRuby: the later
# name is a constant for the earlier class. EWOULDBLOCK is EAGAIN everywhere;
# EOPNOTSUPP is ENOTSUP and EDEADLOCK is EDEADLK on Linux, while macOS gives
# EOPNOTSUPP and ENOTSUP numbers of their own. Every line answers the same
# on both.

p Errno::EWOULDBLOCK
p Errno::EWOULDBLOCK == Errno::EAGAIN
p Errno::EWOULDBLOCK.name
p Errno::EWOULDBLOCK::Errno == Errno::EAGAIN::Errno
k = Errno::EWOULDBLOCK
p k == Errno::EAGAIN

begin
  raise Errno::EWOULDBLOCK, "x"
rescue Errno::EAGAIN => e
  p e.class
  p e.errno == Errno::EAGAIN::Errno
  p e.is_a?(Errno::EWOULDBLOCK)
end

begin
  raise Errno::EAGAIN
rescue Errno::EWOULDBLOCK => e
  p e.class
end

r = begin
  raise Errno::EAGAIN
rescue => e
  case e
  when Errno::EWOULDBLOCK then :would_block
  else :other
  end
end
p r

# a pair that shares a number on one platform and not on another
same = Errno::ENOTSUP::Errno == Errno::EOPNOTSUPP::Errno
p((Errno::ENOTSUP == Errno::EOPNOTSUPP) == same)
p((Errno::EOPNOTSUPP.name == "Errno::ENOTSUP") == same)
caught = begin
  raise Errno::EOPNOTSUPP
rescue Errno::ENOTSUP
  true
rescue Errno::EOPNOTSUPP
  false
end
p caught == same

dl = Errno::EDEADLK::Errno == Errno::EDEADLOCK::Errno
p((Errno::EDEADLOCK == Errno::EDEADLK) == dl)
