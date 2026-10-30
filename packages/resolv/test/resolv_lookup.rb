# Resolv.getaddress and friends: a literal answers itself, localhost comes
# from the hosts file or the system resolver, and a name with no address is
# an empty list from getaddresses and a ResolvError from getaddress.
require "resolv"

p Resolv.getaddresses("192.0.2.7")
p Resolv.getaddresses("::1")
p Resolv.getaddress("10.1.2.3")
p Resolv.getaddresses("localhost").include?("127.0.0.1")
seen = []
Resolv.each_address("127.0.0.1") { |a| seen << a }
p seen
p Resolv.getaddresses("no-such-host.invalid")
begin
  Resolv.getaddress("no-such-host.invalid")
rescue Resolv::ResolvError => e
  puts e.message
end
p Resolv::ResolvError.ancestors.include?(StandardError)
p %w[1.2.3.4 256.1.1.1 fe80::1%lo0 ::ffff:10.0.0.1 example.com].map { |s| Resolv::AddressRegex.match?(s) }
