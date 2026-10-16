# SMTP AUTH against a server in this same program: what PLAIN, LOGIN and
# XOAUTH2 put on the wire, the error a refused login raises, and the
# arguments start checks before it connects. CRAM-MD5 is not here; see
# docs/limitations.md.
require "net/smtp"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]

# The last connection refuses the password.
outcomes = [:accept, :accept, :accept, :reject]

t = Thread.new do
  transcripts = []
  outcomes.each do |outcome|
    c = server.accept
    seen = []
    c.write "220 fake ESMTP ready\r\n"
    while (line = c.gets)
      seen << line.chomp
      case line
      when /\AEHLO/
        c.write "250-fake.example\r\n250 AUTH PLAIN LOGIN XOAUTH2\r\n"
      when /\AAUTH LOGIN/
        c.write "334 VXNlcm5hbWU6\r\n"
        seen << "  user #{c.gets.chomp}"
        c.write "334 UGFzc3dvcmQ6\r\n"
        seen << "  pass #{c.gets.chomp}"
        c.write(outcome == :accept ? "235 2.7.0 ok\r\n" : "535 5.7.8 bad credentials\r\n")
      when /\AAUTH/
        c.write(outcome == :accept ? "235 2.7.0 ok\r\n" : "535 5.7.8 bad credentials\r\n")
      when /\AQUIT/
        c.write "221 2.0.0 bye\r\n"
        break
      end
    end
    c.close
    transcripts << seen
  end
  transcripts
end

opts = { tls: false, starttls: false }
[:plain, :login, :xoauth2].each do |type|
  Net::SMTP.start("127.0.0.1", port, "client.example", "user", "secret", type, **opts) do |smtp|
    p [type, smtp.capable_auth_types]
  end
end

begin
  Net::SMTP.start("127.0.0.1", port, "client.example", "user", "wrong", :login, **opts) { }
rescue Net::SMTPAuthenticationError => e
  p e.class, e.message, e.response.status
  p e.is_a?(Net::SMTPError), e.is_a?(Net::ProtoAuthError)
end

# An unknown type and a missing password fail before any connection.
begin
  Net::SMTP.start("127.0.0.1", port, "client.example", "user", "secret", :nope, **opts) { }
rescue ArgumentError => e
  p e.message
end
begin
  Net::SMTP.start("127.0.0.1", port, "client.example", "user", nil, :plain, **opts) { }
rescue ArgumentError => e
  p e.message
end

t.value.each_with_index do |seen, i|
  puts "-- connection #{i + 1}"
  seen.each { |l| puts l }
end
