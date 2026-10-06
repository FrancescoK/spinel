# A Regexp that is no literal (interpolated into a constant, built with
# Regexp.new) matches in a case/when as a literal does: the when never matched.
module Pattern
  OCTET = "(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
  IPV4 = /\A#{OCTET}\.#{OCTET}\.#{OCTET}\.#{OCTET}\z/
end

def kind(ip)
  case ip
  when Pattern::IPV4 then :ipv4
  when /:/ then :ipv6
  else :none
  end
end

p kind("192.168.1.20")
p kind("::1")
p kind("300.1.1.1")

word = Regexp.new("\\A(h\\w+)\\z")
case "hello"
when word then p $1
else p :none
end

case :hello
when word then p :symbol
else p :none
end

[1, "hey", :hum, nil].each do |v|
  r = case v
      when word then :matched
      else :none
      end
  p r
end
