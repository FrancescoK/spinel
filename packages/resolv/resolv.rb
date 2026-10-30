# Spinel package: resolv
#
# The address half of Ruby's resolv library: Resolv.getaddress,
# Resolv.getaddresses and Resolv.each_address, with Resolv::ResolvError and
# Resolv::Hosts.
#
# The order is CRuby's. An IPv4 or IPv6 literal answers itself. Otherwise
# the hosts file is read first, and only a name it does not list goes on to
# DNS. A name the hosts file lists more than once answers its addresses in
# the reverse of the file's order, as CRuby's Resolv::Hosts does.
#
# What differs is how DNS is asked. CRuby's Resolv::DNS is a resolver of its
# own, written in Ruby over UDP, that reads /etc/resolv.conf. Here the name
# goes to the system resolver (getaddrinfo) instead, so it is answered the
# way the operating system is configured to answer it -- nsswitch, mDNS and
# a VPN's split DNS included, which CRuby's resolver does not consult -- and
# the addresses come in the system's order.
#
# Absent, and so failing to compile when named: reverse lookup (getname,
# getnames, each_name), Resolv::DNS and its record queries (getresource and
# the Resource classes), Resolv::MDNS, and Resolv::IPv4 / Resolv::IPv6 as
# objects -- every address here is a String, as Resolv.getaddress answers it.
require "socket"

class Resolv
  class ResolvError < StandardError
  end

  # CRuby's Resolv::IPv4::Regex and Resolv::IPv6::Regex, spelled without
  # the /x layout and the interpolation they are built with there, and
  # AddressRegex, either of them, as CRuby's is.
  IPV4_REGEX = /\A(?:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?)\.(?:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?)\.(?:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?)\.(?:0|1(?:[0-9][0-9]?)?|2(?:[0-4][0-9]?|5[0-5]?|[6-9])?|[3-9][0-9]?)\z/
  IPV6_REGEX = /(?:\A(?:[0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}\z)|(?:\A(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?::(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?\z)|(?:\A(?:[0-9A-Fa-f]{1,4}:){6}\d+\.\d+\.\d+\.\d+\z)|(?:\A(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?::(?:[0-9A-Fa-f]{1,4}:)*\d+\.\d+\.\d+\.\d+\z)|(?:\A[Ff][Ee]80(?::[0-9A-Fa-f]{1,4}){7}%[-0-9A-Za-z._~]+\z)|(?:\A[Ff][Ee]80:(?:(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?::(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?|:(?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)?:[0-9A-Fa-f]{1,4}%[-0-9A-Za-z._~]+\z)/
  AddressRegex = /(?:#{IPV4_REGEX})|(?:#{IPV6_REGEX})/

  # The first address, or ResolvError when there is none.
  def self.getaddress(name)
    each_address(name) { |address| return address }
    raise ResolvError, "no address for #{name}"
  end

  # Every address, or an empty Array when there is none.
  def self.getaddresses(name)
    ret = []
    each_address(name) { |address| ret << address }
    ret
  end

  def self.each_address(name)
    name = name.to_s
    if AddressRegex.match?(name)
      yield name
      return nil
    end
    yielded = false
    Hosts.new.each_address(name) do |address|
      yielded = true
      yield address
    end
    return nil if yielded
    SystemResolver.new.each_address(name) { |address| yield address }
    nil
  end

  class Hosts
    # CRuby's Windows answer comes from the registry (win32/resolv); this is
    # the path that answer has unless an administrator moved it.
    DefaultFileName = if RUBY_PLATFORM.include?("mingw") || RUBY_PLATFORM.include?("mswin")
      "#{ENV["SystemRoot"] || "C:/Windows"}/System32/drivers/etc/hosts"
    else
      "/etc/hosts"
    end

    def initialize(filename = DefaultFileName)
      @filename = filename
      @loaded = false
      @name2addr = {}
    end

    def getaddress(name)
      each_address(name) { |address| return address }
      raise ResolvError, "#{@filename} has no name: #{name}"
    end

    def getaddresses(name)
      ret = []
      each_address(name) { |address| ret << address }
      ret
    end

    def each_address(name)
      load
      list = @name2addr[name]
      list.each { |address| yield address } unless list.nil?
      nil
    end

    private

    # CRuby's reading, as it is: a `#` starts a comment, the first field is
    # the address and each further field a name for it. The address is not
    # checked, there or here, and a line that starts with whitespace gives
    # an empty first field, as `split(/\s+/)` does there. A file that cannot be read raises from the
    # first lookup, Errno::ENOENT for a missing one, as CRuby's does.
    def load
      return if @loaded
      File.readlines(@filename).each do |line|
        fields = line.sub(/#.*/, "").split(/\s+/)
        next if fields.empty?
        address = fields[0]
        fields[1..].each do |host|
          (@name2addr[host] ||= []) << address
        end
      end
      @name2addr.each_value(&:reverse!)
      @loaded = true
    end
  end

  # Not CRuby's: what stands where its Resolv::DNS stands in the lookup.
  # CRuby's DNS answers Resolv::IPv4 / IPv6 objects, which this package does
  # not have, so it is not offered under that name.
  class SystemResolver
    # A name with no address is an empty answer, as it is from CRuby's
    # resolver, rather than getaddrinfo's SocketError.
    def each_address(name)
      begin
        infos = Socket.getaddrinfo(name, nil, nil, Socket::SOCK_STREAM)
      rescue SocketError
        return nil
      end
      seen = {}
      infos.each do |info|
        address = info[3].to_s
        next if seen.key?(address)
        seen[address] = true
        yield address
      end
      nil
    end
  end
end
