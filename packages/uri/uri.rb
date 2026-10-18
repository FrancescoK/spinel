# Spinel bundled `uri`.
#
# The spelling is CRuby's. URI.parse answers the class of the scheme --
# URI::HTTP, HTTPS, FTP, File, WS, WSS, MailTo -- or URI::Generic, with the
# component readers and writers, #to_s, #request_uri, #merge, #normalize and
# the rest a parsed URI is read with; URI.split, URI.join, the www-form and
# URI-component codecs, and DEFAULT_PARSER. What is not here is absent the
# way a subset is absent things, and a program naming it fails to compile
# rather than at run time:
#
# * no URI::LDAP, and no scheme registry (URI.register_scheme,
#   URI.scheme_list) to add a class to
# * no URI.extract or URI.regexp; the component writers do not validate
#   what they are given
# * the URI.escape family CRuby removed is not here either
require "socket"

module URI
  class Error < StandardError
  end

  class InvalidURIError < Error
  end

  class InvalidComponentError < Error
  end

  class BadURIError < Error
  end

  # The regexp sources CRuby's RFC 2396 parser builds itself from, which a
  # server reads to match what a request carries -- webrick matches a Host
  # header with `URI::RFC2396_Parser.new.pattern.fetch(:HOST)`. #pattern
  # answers the table up to :USERINFO, each source spelled as CRuby spells
  # it; the path and whole-URI patterns after it, the #regexp table, and
  # the parser's own #parse/#split/#escape are absent.
  class RFC2396_Parser
    module PATTERN
      ALPHA = "a-zA-Z"
      ALNUM = "#{ALPHA}\\d"
      HEX = "a-fA-F\\d"
      ESCAPED = "%[#{HEX}]{2}"
      UNRESERVED = "\\-_.!~*'()#{ALNUM}"
      RESERVED = ";/?:@&=+$,\\[\\]"
      DOMLABEL = "(?:[#{ALNUM}](?:[-#{ALNUM}]*[#{ALNUM}])?)"
      TOPLABEL = "(?:[#{ALPHA}](?:[-#{ALNUM}]*[#{ALNUM}])?)"
    end

    attr_reader :pattern

    def initialize
      escaped = PATTERN::ESCAPED
      unreserved = PATTERN::UNRESERVED
      reserved = PATTERN::RESERVED
      uric = "(?:[#{unreserved}#{reserved}]|#{escaped})"
      hostname = "(?:[a-zA-Z0-9\\-.]|%\\h\\h)+"
      ipv4addr = "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}"
      hex4 = "[#{PATTERN::HEX}]{1,4}"
      lastpart = "(?:#{hex4}|#{ipv4addr})"
      hexseq1 = "(?:#{hex4}:)*#{hex4}"
      hexseq2 = "(?:#{hex4}:)*#{lastpart}"
      ipv6addr = "(?:#{hexseq2}|(?:#{hexseq1})?::(?:#{hexseq2})?)"
      ipv6ref = "\\[#{ipv6addr}\\]"
      host = "(?:#{hostname}|#{ipv4addr}|#{ipv6ref})"
      port = "\\d*"
      @pattern = {
        ESCAPED: escaped,
        UNRESERVED: unreserved,
        RESERVED: reserved,
        DOMLABEL: PATTERN::DOMLABEL,
        TOPLABEL: PATTERN::TOPLABEL,
        HOSTNAME: hostname,
        URIC: uric,
        URIC_NO_SLASH: "(?:[#{unreserved};?:@&=+$,]|#{escaped})",
        QUERY: "#{uric}*",
        FRAGMENT: "#{uric}*",
        IPV4ADDR: ipv4addr,
        IPV6ADDR: ipv6addr,
        IPV6REF: ipv6ref,
        HOST: host,
        PORT: port,
        HOSTPORT: "#{host}(?::#{port})?",
        USERINFO: "(?:[#{unreserved};:&=+$,]|#{escaped})*",
      }
    end
  end

  class Generic
    attr_reader :scheme, :userinfo, :host, :port, :path, :query, :fragment
    # The component writers CRuby's Generic has: a parsed URI is edited
    # in place and re-serialised with #to_s (`uri.host = "fxtwitter.com"`
    # is how a Rails app swaps a domain). Assignment only -- CRuby also
    # validates the new component and raises InvalidComponentError on a
    # bad one, which is absent here the way the rest of the subset is.
    attr_writer :scheme, :userinfo, :host, :port, :path, :query, :fragment

    # What follows the scheme of a URI with no hierarchy ("isbn:1" in
    # "urn:isbn:1"); nil for every other URI.
    attr_accessor :opaque

    def hostname=(value)
      @host = value
    end

    def initialize(scheme, userinfo, host, port, path, query, fragment)
      @scheme = scheme
      @userinfo = userinfo
      @host = host
      @port = port
      @path = path
      @query = query
      @fragment = fragment
      @opaque = nil
    end

    # true when the URI names a scheme -- a full URL rather than a bare
    # path such as a request line's "/hello"
    def absolute?
      !@scheme.nil? && !@scheme.empty?
    end

    # The port a scheme's class implies (nil for a scheme with none); a
    # parsed URI with no port of its own takes it.
    def self.default_port
      nil
    end

    def default_port
      self.class.default_port
    end

    # `URI::Generic.build(scheme: "http", host: "x.com")`: a URI from its
    # components, of this class whatever the scheme.
    def self.build(scheme: nil, userinfo: nil, host: nil, port: nil, path: "", query: nil, fragment: nil, opaque: nil)
      u = new(scheme, userinfo, host, port, path, query, fragment)
      u.opaque = opaque
      u
    end

    # The parts of the userinfo "user:password" either side of its first ":".
    def user
      return nil if @userinfo.nil?
      i = @userinfo.index(":")
      i ? @userinfo[0, i] : @userinfo
    end

    def password
      return nil if @userinfo.nil?
      @userinfo.split(":", 2)[1]
    end

    def relative?
      !absolute?
    end

    # The scheme and the host in lower case, and "/" for an empty path, in
    # place; #normalize answers a normalized copy.
    def normalize!
      @path = "/" if !@path.nil? && @path.empty?
      @scheme = @scheme.downcase unless @scheme.nil?
      # CRuby's answer is its last statement: the host it lowered, else nil.
      return nil if @host.nil? || @host == @host.downcase
      @host = @host.downcase
    end

    def normalize
      u = dup
      u.normalize!
      u
    end

    # What goes on the request line: the path with the query, and "/" when the
    # path is empty -- `URI("http://example.com").request_uri` is "/".
    def request_uri
      p = (@path.nil? || @path.empty?) ? "/" : @path
      @query.nil? ? p : "#{p}?#{@query}"
    end

    # the host without the brackets an IPv6 address carries in a URI, as
    # CRuby's URI::Generic#hostname answers it
    def hostname
      v = @host
      v && v.start_with?("[") && v.end_with?("]") ? v[1..-2] : v
    end

    def to_s
      s = String.new
      s << "#{@scheme}:" unless @scheme.nil? || @scheme.empty?
      if @opaque.nil?
        # The authority's "//" goes in whenever there is a host, so a
        # network-path reference ("//host/x") keeps it; file URIs keep
        # it with an empty host, as CRuby does ("file:///etc").
        s << "//" if !@host.nil? || @scheme == "file" || @scheme == "postgres"
        s << "#{@userinfo}@" unless @userinfo.nil?
        s << @host.to_s
        # A cleared port (`uri.port = nil`) is omitted, as CRuby omits it.
        s << ":#{@port}" if !@port.nil? && @port != default_port
        s << @path.to_s
        s << "?#{@query}" unless @query.nil?
      else
        s << @opaque
      end
      s << "##{@fragment}" unless @fragment.nil?
      s
    end

    # Resolves +oth+ (a URI or a String) against this URI, as CRuby's
    # URI::Generic#merge does: an absolute reference is returned as it is,
    # one with an authority ("//host/x") keeps only the scheme, an absolute
    # path replaces the path, and a relative path is merged with this one's
    # directory, "." and ".." segments removed. The query and fragment come
    # from the reference. Raises BadURIError when both URIs are relative.
    def merge(oth)
      rel = URI.for_merge(oth)
      return rel if rel.absolute?
      raise BadURIError, "both URI are relative" unless absolute?

      base = dup
      authority = !rel.userinfo.nil? || !rel.host.nil? || !rel.port.nil?

      # Only a fragment (or nothing at all): this URI with that fragment.
      if (rel.path.nil? || rel.path.empty?) && !authority && rel.query.nil?
        base.fragment = rel.fragment unless rel.fragment.nil?
        return base
      end

      base.query = nil
      base.fragment = nil
      if authority
        # The reference's authority replaces the base's whole: a port it
        # leaves out is the scheme's default, not the base's.
        base.userinfo = rel.userinfo
        base.host = rel.host
        base.port = rel.port.nil? ? base.default_port : rel.port
        base.path = rel.path.to_s
      elsif base.opaque.nil?
        base.path = merge_path(base.path.to_s, rel.path.to_s)
      end
      base.query = rel.query unless rel.query.nil?
      base.fragment = rel.fragment unless rel.fragment.nil?
      base
    end
    def +(oth)
      merge(oth)
    end

    private

    # The path of #merge for a relative-path reference: +rel+ appended to
    # the directory of +base+, then its "." and ".." segments resolved; a
    # ".." that would climb above the root is dropped.
    def merge_path(base, rel)
      base_path = base.split("/", -1)
      rel_path = rel.split("/", -1)

      base_path << "" if base_path.last == ".."
      while (i = base_path.index(".."))
        base_path.slice!(i - 1, 2)
      end

      first = rel_path.first
      if first && first.empty?
        base_path.clear
        rel_path.shift
      end

      rel_path.push("") if rel_path.last == "." || rel_path.last == ".."
      rel_path.delete(".")

      tmp = []
      rel_path.each do |x|
        if x == ".." && !(tmp.empty? || tmp.last == "..")
          tmp.pop
        else
          tmp << x
        end
      end

      add_trailer_slash = !tmp.empty?
      if base_path.empty?
        base_path = [""]
      elsif add_trailer_slash
        base_path.pop
      end
      while (x = tmp.shift)
        if x == ".."
          base_path.pop if base_path.size > 1
        else
          base_path << x
          tmp.each { |t| base_path << t }
          add_trailer_slash = false
          break
        end
      end
      base_path.push("") if add_trailer_slash
      base_path.join("/")
    end

    public

    # #merge, in place: nil when it changes nothing.
    def merge!(oth)
      t = merge(oth)
      return nil if self == t
      replace!(t)
      self
    end

    # A relative reference from +oth+ to this URI -- the inverse of #merge,
    # `URI("http://a/b/c/d") - "http://a/b/"` is "c/d". A URI of another
    # scheme, or on another host, comes back absolute.
    def route_from(oth)
      oth = URI.for_merge(oth)
      raise BadURIError, "relative URI: #{self}" if relative?
      raise BadURIError, "relative URI: #{oth}" if oth.relative?
      return dup if @scheme != oth.scheme

      rel = Generic.new(nil, @userinfo, @host, @port, @path, @query, @fragment)
      rel.opaque = @opaque
      if rel.userinfo != oth.userinfo || rel.host.to_s.downcase != oth.host.to_s.downcase || rel.port != oth.port
        return dup if @userinfo.nil? && @host.nil?
        rel.port = nil if rel.port == oth.default_port
        return rel
      end
      rel.userinfo = nil
      rel.host = nil
      rel.port = nil
      if !rel.path.nil? && rel.path == oth.path
        rel.path = ""
        rel.query = nil if rel.query == oth.query
        return rel
      elsif !rel.opaque.nil? && rel.opaque == oth.opaque
        rel.opaque = ""
        rel.query = nil if rel.query == oth.query
        return rel
      end
      rel.path = route_from_path(oth.path.to_s, @path.to_s)
      rel.path = "" if rel.path == "./" && !@query.nil?
      rel
    end

    def -(oth)
      route_from(oth)
    end

    # The reference from this URI to +oth+: `URI("http://a/b/").route_to("http://a/b/c")` is "c".
    def route_to(oth)
      URI.for_merge(oth).route_from(self)
    end

    # The components of this URI's class, by name: `select(:host, :port)`.
    def select(*components)
      components.map do |c|
        unless component.include?(c)
          raise ArgumentError, "expected of components of #{self.class} (#{self.class.component.join(', ')})"
        end
        component_value(c)
      end
    end

    def self.component
      [:scheme, :userinfo, :host, :port, :registry, :path, :opaque, :query, :fragment]
    end

    def component
      self.class.component
    end

    # Generic.build from a Hash or the components in order, as CRuby's build2.
    def self.build2(args)
      build(args)
    end

    def self.use_registry
      false
    end

    # A String operand of a URI operator is parsed: `"http://a/" + uri`.
    def coerce(oth)
      raise TypeError, "#{oth.class} can't be coerced into #{self.class}" unless oth.is_a?(String)
      [URI.parse(oth), self]
    end

    def hierarchical?
      !@path.nil?
    end

    def absolute
      absolute?
    end

    def to_str
      to_s
    end

    # The user and the password, "%XX" decoded.
    def decoded_user
      u = user
      u.nil? ? nil : URI.decode_uri_component(u)
    end

    def decoded_password
      pw = password
      pw.nil? ? nil : URI.decode_uri_component(pw)
    end

    # The user (with the password after a ":" in it), as CRuby's #user= sets
    # both from one string; #password= keeps the user and replaces the rest.
    def user=(v)
      @userinfo = v
    end

    def password=(v)
      u = user
      raise InvalidURIError, "password component depends user component" if u.nil?
      @userinfo = v.nil? ? u : "#{u}:#{v}"
    end

    # The proxy +env+ names for this URI's scheme ("http_proxy", or
    # "HTTP_PROXY"), as a URI; nil for a loopback host or one +no_proxy+
    # excludes. Under CGI (REQUEST_METHOD set) an HTTP_PROXY is the
    # client's Proxy header, so only the lower-case name counts, or
    # CGI_HTTP_PROXY. CRuby resolves the host with IPSocket.getaddress,
    # which Spinel's socket has no run-time body for: Socket.getaddrinfo.
    def find_proxy(env = ENV)
      raise BadURIError, "relative URI: #{self}" if relative?
      name = "#{@scheme.downcase}_proxy"
      proxy_uri = nil
      if name == "http_proxy" && env.key?("REQUEST_METHOD")
        hits = env.keys.select { |k| k =~ /\Ahttp_proxy\z/i }
        if hits.size == 1
          proxy_uri = env[name] if hits[0] == "http_proxy" && env["HTTP_PROXY"].nil?
        elsif hits.size > 1
          proxy_uri = env[name]
        end
        proxy_uri = env["CGI_HTTP_PROXY"] if proxy_uri.nil?
      elsif name == "http_proxy"
        proxy_uri = env[name]
        if proxy_uri.nil?
          proxy_uri = env["HTTP_PROXY"]
          warn "The environment variable HTTP_PROXY is discouraged.  Please use http_proxy instead." unless proxy_uri.nil?
        end
      else
        proxy_uri = env[name] || env[name.upcase]
      end
      return nil if proxy_uri.nil? || proxy_uri.empty?

      addr = nil
      h = hostname
      unless h.nil?
        begin
          addr = Socket.getaddrinfo(h, nil)[0][3]
        rescue SocketError
          addr = nil
        end
        return nil if !addr.nil? && addr =~ /\A127\.|\A::1\z/
      end
      no_proxy = env["no_proxy"] || env["NO_PROXY"]
      return nil if !no_proxy.nil? && !Generic.use_proxy?(h.to_s, addr, @port, no_proxy)
      # a copy: --share-strings refuses the String env holds, shared with name's lookup
      URI.parse(proxy_uri.dup)
    end

    # false when +no_proxy+ ("example.com,.local:8080,10.0.0.0/8") names
    # +hostname+, its domain, or a network holding +addr+.
    def self.use_proxy?(hostname, addr, port, no_proxy)
      hostname = hostname.downcase
      dothostname = ".#{hostname}"
      no_proxy.scan(/([^:,\s]+)(?::(\d+))?/) do |m|
        p_host = m[0]
        p_port = m[1]
        next unless p_port.nil? || port == p_port.to_i
        if p_host.start_with?(".")
          return false if hostname.end_with?(p_host.downcase)
        elsif dothostname.end_with?(".#{p_host.downcase}")
          return false
        end
        # CRuby's IPAddr.new(p_host).include?(addr), a host name skipped.
        return false if !addr.nil? && URI.ip_network_include?(p_host, addr)
      end
      true
    end

    def inspect
      "#<#{self.class} #{self}>"
    end

    # Equal when of the same class with the same components once normalized.
    def ==(other)
      other.is_a?(Generic) && self.class == other.class && normalize.component_ary == other.normalize.component_ary
    end

    def eql?(other)
      other.is_a?(Generic) && self.class == other.class && component_ary == other.component_ary
    end

    def hash
      component_ary.hash
    end

    protected

    def component_ary
      component.map { |c| component_value(c) }
    end

    # Takes every component of +oth+, a URI of this class (#merge!).
    def replace!(oth)
      raise ArgumentError, "expected #{self.class} object" if self.class != oth.class
      @scheme = oth.scheme
      @userinfo = oth.userinfo
      @host = oth.host
      @port = oth.port
      @path = oth.path
      @query = oth.query
      @fragment = oth.fragment
      @opaque = oth.opaque
    end

    # One component by name: what #select and #== read.
    def component_value(c)
      case c
      when :scheme then @scheme
      when :userinfo then @userinfo
      when :host then @host
      when :port then @port
      when :path then @path
      when :opaque then @opaque
      when :query then @query
      when :fragment then @fragment
      else nil
      end
    end

    private

    # #route_from's path: the dot-segments that climb from the directory of
    # +src+ to +dst+.
    def route_from_path(src, dst)
      return "" if dst == src
      return dst.dup if dst =~ %r{(?:\A|/)\.\.?(?:/|\z)}
      src_path = src.scan(%r{[^/]*/})
      dst_path = dst.scan(%r{[^/]*/?})
      while !dst_path.empty? && dst_path.first == src_path.first
        src_path.shift
        dst_path.shift
      end
      tmp = dst_path.join
      if src_path.empty?
        return "./" if tmp.empty?
        return "./#{tmp}" if dst_path.first.include?(":")
        return tmp
      end
      ("../" * src_path.size) + tmp
    end

    public
  end

  # `URI::HTTPS.build(host: "api.github.com", path: "/x")` -- a URI from
  # its components rather than from a string. CRuby also takes an Array
  # of components in order, and validates each one; the keyword form is
  # the one an application writes, and validation is absent here the way
  # it is for the component writers above. A port not given is the
  # scheme's default, which #to_s leaves off, as CRuby does.
  class HTTP < Generic
    def self.default_port
      80
    end

    def self.component
      [:scheme, :userinfo, :host, :port, :path, :query, :fragment]
    end

    def self.build(userinfo: nil, host: nil, port: nil, path: "", query: nil, fragment: nil)
      HTTP.new("http", userinfo, host, port || 80, path, query, fragment)
    end

    # The host, with ":port" when the port is not the scheme's default --
    # CRuby's URI::HTTP#authority. An absent port is left off, as #to_s
    # leaves it off.
    def authority
      if @port.nil? || @port == default_port || @port <= 0
        @host.to_s
      else
        "#{@host}:#{@port}"
      end
    end

    # "scheme://authority", the web origin a CSP source or a same-origin
    # check compares -- CRuby's URI::HTTP#origin. No userinfo, path, query
    # or fragment.
    def origin
      "#{@scheme}://#{authority}"
    end
  end

  class HTTPS < HTTP
    def self.default_port
      443
    end

    def self.build(userinfo: nil, host: nil, port: nil, path: "", query: nil, fragment: nil)
      HTTPS.new("https", userinfo, host, port || 443, path, query, fragment)
    end
  end

  # An FTP URI's path is relative to the login directory: it is kept
  # without the "/" that separates it from the authority, an absolute one
  # is written with "%2F" in its place, and a trailing ";type=a|i|d" is
  # its typecode.
  class FTP < Generic
    attr_reader :typecode

    def self.default_port
      21
    end

    def self.component
      [:scheme, :userinfo, :host, :port, :path, :typecode]
    end

    protected

    def component_value(c)
      c == :typecode ? @typecode : super
    end

    public

    def initialize(scheme, userinfo, host, port, path, query, fragment)
      super
      @typecode = nil
      rel = @path.to_s
      rel = rel[1..-1].to_s if rel.start_with?("/")
      rel = "/#{rel[3..-1]}" if rel.start_with?("%2F")
      ti = rel.index(";type=")
      if ti
        @typecode = rel[(ti + 6)..-1]
        rel = rel[0, ti]
      end
      @path = rel
    end

    def to_s
      s = String.new
      s << "#{@scheme}://"
      s << "#{@userinfo}@" unless @userinfo.nil?
      s << @host.to_s
      s << ":#{@port}" if !@port.nil? && @port != default_port
      rel = @path.to_s
      s << "/" << (rel.start_with?("/") ? "%2F#{rel[1..-1]}" : rel)
      s << ";type=#{@typecode}" unless @typecode.nil?
      s << "?#{@query}" unless @query.nil?
      s << "##{@fragment}" unless @fragment.nil?
      s
    end
  end

  class File < Generic
    def self.component
      [:scheme, :host, :path]
    end
  end

  class WS < Generic
    def self.default_port
      80
    end

    def self.component
      [:scheme, :userinfo, :host, :port, :path, :query]
    end
  end

  class WSS < WS
    def self.default_port
      443
    end
  end

  # `mailto:to?hname=hvalue&...`: the addresses before the "?", and the
  # headers after it as [name, value] pairs, both as written.
  class MailTo < Generic
    def self.component
      [:scheme, :to, :headers]
    end

    protected

    def component_value(c)
      case c
      when :to then to
      when :headers then headers
      else super
      end
    end

    public

    def to
      o = @opaque.to_s
      i = o.index("?")
      i ? o[0, i] : o
    end

    def headers
      o = @opaque.to_s
      i = o.index("?")
      return [] unless i
      o[(i + 1)..-1].to_s.split("&").map { |h| h.split("=", 2) }
    end
  end

  # The class a scheme's URI is parsed as.
  def self.scheme_class(scheme)
    case scheme
    when "http" then HTTP
    when "https" then HTTPS
    when "ftp" then FTP
    when "file" then File
    when "ws" then WS
    when "wss" then WSS
    when "mailto" then MailTo
    else Generic
    end
  end

  # Percent-encode one www-form component: everything but the unreserved set,
  # with a space as "+", which is what CRuby does here (and what differs from
  # a path escape).
  def self.encode_www_form_component(str)
    out = String.new
    str.to_s.each_char do |ch|
      if ch =~ /\A[A-Za-z0-9\*\-\.\_]\z/
        out << ch
      elsif ch == " "
        out << "+"
      else
        ch.bytes.each { |b| out << format("%%%02X", b) }
      end
    end
    out
  end

  # The value of one hex digit character, or nil for anything else.
  def self.hex_digit(c)
    return nil unless c
    o = c.ord
    return o - 48 if o >= 48 && o <= 57
    return o - 55 if o >= 65 && o <= 70
    return o - 87 if o >= 97 && o <= 102
    nil
  end

  def self.decode_www_form_component(str, enc = Encoding::UTF_8)
    percent_decode(str, enc, true)
  end

  # `encode_www_form_component` with a space as "%20", as CRuby's
  # URI.encode_uri_component answers.
  def self.encode_uri_component(str)
    encode_www_form_component(str).gsub("+", "%20")
  end

  # `decode_www_form_component` with "+" left as it is.
  def self.decode_uri_component(str, enc = Encoding::UTF_8)
    percent_decode(str, enc, false)
  end

  # Each "%" and two hex digits as that byte, and with +plus+ each "+" as a
  # space; any other "%" is CRuby's ArgumentError.
  def self.percent_decode(str, enc, plus)
    out = String.new
    s = str.to_s
    i = 0
    while i < s.length
      ch = s[i]
      if plus && ch == "+"
        out << " "
        i += 1
      elsif ch == "%"
        # a % not followed by two hex digits is CRuby's ArgumentError
        h1 = hex_digit(s[i + 1])
        h2 = hex_digit(s[i + 2])
        raise ArgumentError, "invalid %-encoding (#{s})" unless h1 && h2
        out << (h1 * 16 + h2).chr
        i += 3
      else
        out << ch
        i += 1
      end
    end
    out.force_encoding(enc)
  end

  # The www-form decoding of one key or value: "+" is a space and a "%" with two
  # hex digits is that byte. Unlike decode_www_form_component, a "%" that is not
  # followed by two hex digits is left as it is, not an error.
  def self.decode_www_form_lenient(s, enc = Encoding::UTF_8)
    out = String.new
    i = 0
    while i < s.length
      ch = s[i]
      if ch == "+"
        out << " "
        i += 1
      elsif ch == "%" && hex_digit(s[i + 1]) && hex_digit(s[i + 2])
        out << (hex_digit(s[i + 1]) * 16 + hex_digit(s[i + 2])).chr
        i += 3
      else
        out << ch
        i += 1
      end
    end
    out.force_encoding(enc).scrub
  end

  # `URI.decode_www_form("a=1&b=x+y")` -> [["a", "1"], ["b", "x y"]]. Keys and
  # values take the encoding argument, UTF-8 by default. `use__charset_` is not
  # supported.
  def self.decode_www_form(str, enc = Encoding::UTF_8, separator: "&", use__charset_: false, isindex: false)
    raise ArgumentError, "the input of URI.decode_www_form must be ASCII only string" unless str.ascii_only?
    raise NotImplementedError, "URI.decode_www_form: use__charset_ is not supported" if use__charset_
    raise NotImplementedError, "URI.decode_www_form: an empty separator is not supported" if separator.empty?
    ary = []
    return ary if str.empty?
    pos = 0
    n = str.length
    sl = separator.length
    while pos < n
      e = str.index(separator, pos)
      if e
        piece = str[pos, e - pos]
        pos = e + sl
      else
        piece = str[pos, n - pos]
        pos = n
      end
      eq = piece.index("=")
      key = eq ? piece[0, eq] : piece
      val = eq ? piece[eq + 1, piece.length - eq - 1] : ""
      if isindex
        if eq.nil?
          val = key
          key = ""
        end
        isindex = false
      end
      ary << [decode_www_form_lenient(key, enc), decode_www_form_lenient(val, enc)]
    end
    ary
  end

  # `URI.encode_www_form({"a" => 1, "b" => "x y"})` -> "a=1&b=x+y"
  def self.encode_www_form(pairs)
    parts = []
    pairs.each do |k, v|
      key = encode_www_form_component(k)
      if v.nil?
        parts << key
      elsif v.respond_to?(:to_ary)
        values = []
        v.to_ary.each do |item|
          values << (item.nil? ? "" : "#{key}=#{encode_www_form_component(item)}")
        end
        parts << values.join("&")
      else
        parts << "#{key}=#{encode_www_form_component(v)}"
      end
    end
    parts.join("&")
  end

  # The characters RFC 3986 excludes from a URI: the space and the
  # control range, plus the "unwise" set a generic URI may not carry
  # unescaped, and the brackets an authority reserves for an IPv6
  # literal. CRuby's parser rejects a string containing any of them
  # with `InvalidURIError`, and an app can be RELYING on that rescue
  # rather than on its own validation -- a Rails message body decides
  # whether to keep a link by asking whether `URI.parse` accepted it,
  # so a parser that accepts everything turns that check into a no-op.
  # `"http://exa mple.com/ "` is the shape that surfaced it: with a
  # space admitted, the host reads as an ordinary off-site domain.
  INVALID_URI_CHARS = " <>\"{}|\\^`[]"

  # Where each of them is excluded is not uniform, and CRuby's own parser is
  # what this follows: the QUERY (between the first `?` and the first `#`)
  # takes any ASCII character, including a space and the unwise set, so
  # `?filter=a|b` parses; everywhere else -- the scheme, the authority, the
  # path and the fragment -- the set above is rejected. A bracket is the
  # exception inside an authority, where `http://[::1]/x` is an IPv6 host.
  # A byte outside ASCII is rejected everywhere, query included.
  def self.invalid_char?(s)
    qi = s.index("?")
    fi = s.index("#")
    qi = nil if qi && fi && fi < qi          # `#a?b` is all fragment
    auth_end = -1
    # the authority follows "scheme://", or the "//" that opens a
    # network-path reference ("//[::1]:81/x")
    ai = s.start_with?("//") ? -1 : s.index("://")
    # (read through to_i: an Integer-or-nil's `+` reaches every class's +)
    a3 = ai.to_i + 3
    if ai
      auth_end = s.length
      i = a3
      while i < s.length
        c = s[i]
        if c == "/" || c == "?" || c == "#"
          auth_end = i
          break
        end
        i += 1
      end
    end
    # the host inside the authority, after any `user:pw@`
    host_start = -1
    host_end = -1
    if ai
      host_start = a3
      j = host_start
      while j < auth_end
        host_start = j + 1 if s[j] == "@"
        j += 1
      end
      host_end = auth_end
      j = host_start
      while j < auth_end
        if s[j] == "]"
          host_end = j + 1
          break
        end
        j += 1
      end
    end
    i = 0
    while i < s.length
      c = s[i]
      o = c.ord
      return true if o > 0x7f
      in_query = qi && i > qi && (fi.nil? || i < fi)
      unless in_query
        return true if o < 0x20 || o == 0x7f
        if INVALID_URI_CHARS.include?(c)
          # a bracketed IPv6 host: `[` opens the host and `]` closes it, with
          # only a `:port` allowed after. Anything else bracketed is rejected
          # the way CRuby rejects `http://exa[mple.com/`.
          bracket_host = (c == "[" && i == host_start) ||
                         (c == "]" && i == host_end - 1 && host_end > host_start + 1 &&
                          s[host_start] == "[")
          return true unless bracket_host
        end
      end
      i += 1
    end
    false
  end

  # Splits +str+ the RFC 3986 way: an optional "scheme:", then either an
  # opaque part (a scheme followed by no "/", as in "urn:isbn:1") or a
  # hierarchical part -- an optional "//authority", the path, "?query" --
  # and "#fragment". With no scheme it is a relative reference: "c" and
  # "../d" are paths, and only "//host/x" carries a host. The parts, as
  # CRuby's URI.split answers them: scheme, userinfo, host, port (as
  # written), registry, path, opaque, query, fragment.
  def self.split(str)
    s = str.to_s
    raise InvalidURIError, "bad URI (is not URI?): #{s.inspect}" if invalid_char?(s)

    fragment = nil
    fi = s.index("#")
    if fi
      fragment = s[(fi + 1)..-1].to_s
      s = s[0, fi]
    end

    scheme = nil
    rest = s
    ci = s.index(":")
    if ci && ci > 0 && s[0, ci] =~ /\A[A-Za-z][A-Za-z0-9+\-.]*\z/
      scheme = s[0, ci].downcase
      rest = s[(ci + 1)..-1].to_s
    end

    if !scheme.nil? && !rest.empty? && !rest.start_with?("/")
      return [scheme, nil, nil, nil, nil, nil, rest, nil, fragment]
    end

    query = nil
    qi = rest.index("?")
    if qi
      query = rest[(qi + 1)..-1].to_s
      rest = rest[0, qi]
    end

    authority = nil
    path = rest
    if rest.start_with?("//")
      authority = rest[2..-1].to_s
      path = ""
      pi = authority.index("/")
      if pi
        path = authority[pi..-1].to_s
        authority = authority[0, pi]
      end
    end

    userinfo = nil
    host = nil
    port = nil
    if authority
      ai = authority.index("@")
      if ai
        userinfo = authority[0, ai]
        authority = authority[(ai + 1)..-1].to_s
      end
      host = authority
      ci = authority.rindex(":")
      if ci && authority[(ci + 1)..-1].to_s =~ /\A[0-9]*\z/
        host = authority[0, ci]
        port = authority[(ci + 1)..-1].to_s
      end
    end
    [scheme, userinfo, host, port, nil, path, nil, query, fragment]
  end

  def self.parse(str)
    scheme, userinfo, host, port, _registry, path, opaque, query, fragment = split(str)
    klass = scheme_class(scheme)
    if opaque
      if klass == MailTo
        to = opaque.index("?") ? opaque[0, opaque.index("?")] : opaque
        bad = to.split(",", -1).any? { |a| a !~ /\A[^@\s?]+@[^@\s?]+\z/ }
        raise InvalidComponentError, "unrecognised opaque part for mailtoURL: #{opaque}" if !to.empty? && bad
      end
      u = klass.new(scheme, nil, nil, nil, nil, nil, fragment)
      u.opaque = opaque
      return u
    end
    pn = port.nil? || port.empty? ? klass.default_port : port.to_i
    klass.new(scheme, userinfo, host, pn, path, query, fragment)
  end

  # #merge's argument: a URI as it is, a String parsed.
  def self.for_merge(oth)
    if oth.is_a?(Generic)
      oth
    elsif oth.is_a?(String)
      parse(oth)
    else
      raise ArgumentError, "bad argument (expected URI object or URI string)"
    end
  end

  # The RFC 2396 parser's #make_regexp, the pattern CRuby builds for an
  # absolute URI. The rest of the parser (#split, #parse, #escape, the
  # pattern and regexp tables) is not here.
  class RFC2396_Parser
    def make_regexp(schemes = nil)
      x = x_abs_uri
      return Regexp.new(x, Regexp::EXTENDED) unless schemes
      Regexp.new("(?=(?i:#{Regexp.union(*schemes).source}):)#{x}", Regexp::EXTENDED)
    end

    private

    # The pieces of CRuby's initialize_pattern the absolute-URI pattern uses.
    def x_abs_uri
      alpha = "a-zA-Z"
      alnum = "#{alpha}\\d"
      hex = "a-fA-F\\d"
      escaped = "%[#{hex}]{2}"
      unreserved = "\\-_.!~*'()#{alnum}"
      reserved = ";/?:@&=+$,\\[\\]"
      uric = "(?:[#{unreserved}#{reserved}]|#{escaped})"
      uric_no_slash = "(?:[#{unreserved};?:@&=+$,]|#{escaped})"
      query = "#{uric}*"
      fragment = "#{uric}*"
      hostname = "(?:[a-zA-Z0-9\\-.]|%\\h\\h)+"
      ipv4addr = "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}"
      hex4 = "[#{hex}]{1,4}"
      lastpart = "(?:#{hex4}|#{ipv4addr})"
      hexseq1 = "(?:#{hex4}:)*#{hex4}"
      hexseq2 = "(?:#{hex4}:)*#{lastpart}"
      ipv6addr = "(?:#{hexseq2}|(?:#{hexseq1})?::(?:#{hexseq2})?)"
      ipv6ref = "\\[#{ipv6addr}\\]"
      host = "(?:#{hostname}|#{ipv4addr}|#{ipv6ref})"
      userinfo = "(?:[#{unreserved};:&=+$,]|#{escaped})*"
      pchar = "(?:[#{unreserved}:@&=+$,]|#{escaped})"
      param = "#{pchar}*"
      segment = "#{pchar}*(?:;#{param})*"
      path_segments = "#{segment}(?:/#{segment})*"
      reg_name = "(?:[#{unreserved}$,;:@&=+]|#{escaped})+"
      scheme = "[#{alpha}][\\-+.#{alpha}\\d]*"
      abs_path = "/#{path_segments}"
      opaque_part = "#{uric_no_slash}#{uric}*"
      "
        (#{scheme}):                           (?# 1: scheme)
        (?:
           (#{opaque_part})                    (?# 2: opaque)
        |
           (?:(?:
             //(?:
                 (?:(?:(#{userinfo})@)?        (?# 3: userinfo)
                   (?:(#{host})(?::(\\d*))?))? (?# 4: host, 5: port)
               |
                 (#{reg_name})                 (?# 6: registry)
               )
             |
             (?!//))                           (?# XXX: '//' is the mark for hostport)
             (#{abs_path})?                    (?# 7: path)
           )(?:\\?(#{query}))?                 (?# 8: query)
        )
        (?:\\#(#{fragment}))?                  (?# 9: fragment)
      "
    end
  end

  RFC2396_PARSER = RFC2396_Parser.new

  # The parser URI.parse is (URI::DEFAULT_PARSER): #parse, #split and #join
  # answer as URI's own, and #escape / #unescape percent-encode what is
  # neither reserved nor unreserved. #extract, #regexp and #make_regexp
  # are absent.
  class RFC3986_Parser
    def split(uri)
      URI.split(uri)
    end

    def parse(uri)
      URI.parse(uri)
    end

    def join(*uris)
      URI.join(*uris)
    end

    # Each byte of a character outside the unreserved and reserved sets as
    # "%XX"; with +unsafe+, each match of it instead.
    def escape(str, unsafe = nil)
      out = String.new
      if unsafe
        str.to_s.gsub(unsafe) { |m| m.bytes.map { |b| format("%%%02X", b) }.join }
      else
        str.to_s.each_char do |ch|
          if ch =~ /\A[\-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]\z/
            out << ch
          else
            ch.bytes.each { |b| out << format("%%%02X", b) }
          end
        end
        out
      end
    end

    # Each "%" and two hex digits as that byte; any other "%" stays.
    def unescape(str)
      out = String.new
      s = str.to_s
      i = 0
      while i < s.length
        h1 = s[i] == "%" ? URI.hex_digit(s[i + 1]) : nil
        h2 = h1 ? URI.hex_digit(s[i + 2]) : nil
        if h1 && h2
          out << (h1 * 16 + h2).chr
          i += 3
        else
          out << s[i]
          i += 1
        end
      end
      out.force_encoding(Encoding::UTF_8)
    end
  end

  RFC3986_PARSER = RFC3986_Parser.new
  DEFAULT_PARSER = RFC3986_PARSER

  # `URI.join("http://example.com/a/", "b", "../c")`: the first argument
  # parsed, then each of the rest merged onto it in turn.
  def self.join(base, *rels)
    u = for_merge(base)
    rels.each { |r| u = u.merge(r) }
    u
  end

  # The bytes of an IPv4 (4) or IPv6 (16) address, nil for anything else.
  # Not IPAddr: requiring it here would load it into every program using
  # uri, and an app's own IPAddr (a Rails runtime shim) then collides.
  def self.ip_bytes(s)
    if (m = /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\z/.match(s))
      b = [m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i]
      return b.any? { |o| o > 255 } ? nil : b
    end
    return nil unless s.include?(":") && s =~ /\A[0-9A-Fa-f:.]+\z/
    halves = s.split("::", -1)
    return nil if halves.size > 2
    groups = halves.map { |h| h.empty? ? [] : h.split(":", -1) }
    tail = groups.last
    v4 = nil
    if !tail.empty? && tail.last.include?(".")
      v4 = ip_bytes(tail.pop)
      return nil if v4.nil? || v4.size != 4
    end
    words = []
    groups.each do |g|
      ws = []
      g.each do |w|
        return nil unless w =~ /\A[0-9A-Fa-f]{1,4}\z/
        ws << w.to_i(16)
      end
      words << ws
    end
    have = words.flatten.size + (v4.nil? ? 0 : 2)
    if halves.size == 2
      return nil if have > 7
      all = words[0] + Array.new(8 - have, 0) + (words[1] || [])
    else
      return nil if have != 8
      all = words[0]
    end
    bytes = []
    all.each { |w| bytes << (w >> 8) << (w & 0xff) }
    bytes.concat(v4) unless v4.nil?
    bytes
  end

  # Whether the network +net+ ("10.0.0.0/8", "fe80::/10", an address)
  # holds the address +addr+; nil when +net+ is no address.
  def self.ip_network_include?(net, addr)
    base, len = net.split("/", 2)
    nb = ip_bytes(base.to_s)
    return nil if nb.nil?
    bits = nb.size * 8
    prefix = bits
    unless len.nil?
      if len.include?(".")
        mask = ip_bytes(len)
        return nil if mask.nil? || mask.size != nb.size
        prefix = mask.map { |b| b.to_s(2).rjust(8, "0") }.join
        return nil unless prefix =~ /\A1*0*\z/
        prefix = prefix.count("1")
      else
        return nil unless len =~ /\A\d+\z/
        prefix = len.to_i
      end
    end
    return nil if prefix > bits
    ab = ip_bytes(addr.to_s)
    return false if ab.nil? || ab.size != nb.size
    full = prefix / 8
    i = 0
    while i < full
      return false if ab[i] != nb[i]
      i += 1
    end
    rest = prefix % 8
    return true if rest.zero?
    m = (0xff << (8 - rest)) & 0xff
    (ab[full] & m) == (nb[full] & m)
  end
end

# `URI("https://example.com/x")` -- the Kernel method every caller writes.
def URI(str)
  str.is_a?(URI::Generic) ? str : URI.parse(str)
end
