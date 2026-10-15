# Socket's constants are the system's, read by name at run time, and
# const_defined? / defined? see them as CRuby does: they answered false and
# nil. ipaddr guards a fallback for systems without IPv6 this way, and the
# fallback, taken, reopened Socket with a stand-in AF_INET6.
require "socket"

p Socket.const_defined?(:AF_INET6)
p Socket.const_defined?(:SOCK_STREAM)
p Socket.const_defined?("AF_UNIX")
p Socket.const_defined?(:NO_SUCH_CONST)
p defined?(Socket::AF_INET)
p defined?(Socket::NO_SUCH_CONST)

unless Socket.const_defined? :AF_INET6
  class Socket < BasicSocket
    AF_INET6 = Object.new.freeze
  end
end
p Socket::AF_INET6 == Socket::AF_INET6.to_i
