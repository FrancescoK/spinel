# Resolv reads the hosts file first, CRuby's way: comments dropped, a name
# listed twice answered in reverse file order, the address field taken as
# written (not checked, and an indented line's is empty), and a file that
# was missing read on the next lookup.
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
File.write(path, "  10.0.0.9 gamma\n", mode: "a")

hosts = Resolv::Hosts.new(path)
p hosts.getaddresses("alpha")
p hosts.getaddresses("alpha.example")
p hosts.getaddress("alpha")
p hosts.getaddresses("beta")
p hosts.getaddresses("10.0.0.3")
p hosts.getaddresses("ALPHA")
p hosts.getaddresses("gamma")
begin
  hosts.getaddress("beta")
rescue Resolv::ResolvError => e
  puts "ResolvError"
end
late_path = File.join(Dir.tmpdir, "spinel_resolv_late_hosts_#{Process.pid}")
late = Resolv::Hosts.new(late_path)
begin
  late.getaddresses("alpha")
rescue Errno::ENOENT
  puts "ENOENT"
end
File.write(late_path, "10.0.0.5 alpha\n")
p late.getaddresses("alpha")
File.delete(late_path)
File.delete(path)
