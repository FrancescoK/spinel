# spinel: int64
# IPAddr, CRuby's ipaddr.rb: parsing IPv4 and IPv6 with and without a family,
# masks and ranges, and the errors a malformed address or a family mismatch
# raises. json_schemer validates `format: ipv4` / `ipv6` with
# IPAddr.new(data, family) and IPAddr::Error. An IPv6 address past 2**64
# (2001:db8::1) needs --int-overflow=promote, so the IPv6 ones here fit.
require "ipaddr"

p IPAddr.new("192.168.1.10", Socket::AF_INET).to_s
p IPAddr.new("::1", Socket::AF_INET6).to_s
p IPAddr.new("10.0.0.0/8").include?(IPAddr.new("10.1.2.3"))
p IPAddr.new("10.0.0.0/8").include?(IPAddr.new("11.0.0.1"))
net = IPAddr.new("192.168.0.0/24")
p net.prefix, net.to_s
p IPAddr.new("192.168.1.10").ipv4?, IPAddr.new("::1").ipv6?
p IPAddr.new("127.0.0.1").loopback?, IPAddr.new("10.1.2.3").private?
p IPAddr.new("192.168.1.10").to_i, IPAddr.new("192.168.1.10").reverse
p IPAddr.new("192.168.1.10") == IPAddr.new("192.168.1.10")
p (IPAddr.new("10.0.0.1") <=> IPAddr.new("10.0.0.2"))
p IPAddr.new("192.168.1.10").mask(16).to_s
p IPAddr.new("1.2.3.4").ipv4_mapped.to_s
[["1.2.3", Socket::AF_INET], ["zz::1", Socket::AF_INET6], ["::1", Socket::AF_INET],
 ["1.2.3.4", Socket::AF_INET6], ["300.1.1.1", nil]].each do |s, f|
  begin
    f ? IPAddr.new(s, f) : IPAddr.new(s)
    p :ok
  rescue IPAddr::Error => e
    p [e.class, e.message]
  end
end
