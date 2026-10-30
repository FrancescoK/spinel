# Resolv reads the hosts file first, CRuby's way: comments dropped, a
# non-literal address skipped, a name listed twice answered in reverse file
# order, and the address field taken as written.
require "resolv"
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_resolv_hosts_#{Process.pid}")
File.write(path, <<~HOSTS)
  # a comment line
  10.0.0.1   alpha alpha.example   # trailing comment
  10.0.0.2   alpha
  ::1        alpha
  not-an-ip  beta
  10.0.0.3
HOSTS

hosts = Resolv::Hosts.new(path)
p hosts.getaddresses("alpha")
p hosts.getaddresses("alpha.example")
p hosts.getaddress("alpha")
p hosts.getaddresses("beta")
p hosts.getaddresses("10.0.0.3")
p hosts.getaddresses("ALPHA")
begin
  hosts.getaddress("beta")
rescue Resolv::ResolvError => e
  puts "ResolvError"
end
begin
  Resolv::Hosts.new(File.join(Dir.tmpdir, "spinel_resolv_no_such_hosts")).getaddresses("alpha")
rescue Errno::ENOENT
  puts "ENOENT"
end
File.delete(path)
