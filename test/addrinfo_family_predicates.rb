# Addrinfo's family predicates compared their (heap) afname against a bare C
# literal through sp_str_eq, which confirms a strcmp hit by comparing byte
# lengths -- and taking a bare literal's length reads its out-of-bounds s[-1]
# marker. Whatever byte precedes the literal in rodata decides: land on a
# marker value and the predicate answers false for two equal names. The rodata
# layout is the optimizer's choice, so the answer changed between -O0 and -O1.
require "socket"

v4 = Addrinfo.tcp("127.0.0.1", 80)
puts "#{v4.ipv4?} #{v4.ipv6?} #{v4.unix?} #{v4.ip?}"

v6 = Addrinfo.udp("::1", 53)
puts "#{v6.ipv4?} #{v6.ipv6?} #{v6.unix?} #{v6.ip?}"

un = Addrinfo.unix("/tmp/spinel_afp.sock")
puts "#{un.ipv4?} #{un.ipv6?} #{un.unix?} #{un.ip?}"

# through a handle's own address, not just the constructors
srv = TCPServer.new("127.0.0.1", 0)
la = srv.local_address
puts "#{la.ipv4?} #{la.ipv6?} #{la.unix?} #{la.ip?}"
srv.close

# the predicates read their receiver once: each named it twice in its own C
# text, so a receiver that is a call ran twice
$n = 0

def one_addr
  $n += 1
  Addrinfo.tcp("127.0.0.1", 80)
end

puts "#{one_addr.ipv4?} #{$n}"
