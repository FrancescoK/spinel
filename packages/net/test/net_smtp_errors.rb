# The error each SMTP reply class raises, against a server in this same
# program: 4xx is SMTPServerBusy, 500 SMTPSyntaxError, another 5xx
# SMTPFatalError, a code outside the classes SMTPUnknownError. Each one
# carries the reply, and all of them are SMTPError and ProtocolError, so a
# caller can rescue at either level.
require "net/smtp"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]

# What the server answers to RCPT, one connection each.
replies = ["450 4.2.1 mailbox busy", "500 5.5.1 command unrecognized",
           "550 5.1.1 no such user", "650 what is this"]

t = Thread.new do
  transcripts = []
  replies.each do |reply|
    c = server.accept
    seen = []
    c.write "220 fake ESMTP ready\r\n"
    while (line = c.gets)
      seen << line.chomp
      case line
      when /\AEHLO/ then c.write "250 fake.example\r\n"
      when /\AMAIL/ then c.write "250 2.1.0 ok\r\n"
      when /\ARCPT/ then c.write "#{reply}\r\n"
      when /\ARSET/ then c.write "250 2.0.0 ok\r\n"
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

replies.size.times do
  Net::SMTP.start("127.0.0.1", port, "client.example", tls: false, starttls: false) do |smtp|
    smtp.send_message("x\n", "a@example.com", "b@example.com")
  rescue Net::SMTPError => e
    p e.class
    p e.message
    p e.response.status, e.response.continue?, e.response.success?
    p e.is_a?(Net::ProtocolError)
  end
end

t.value.each_with_index do |seen, i|
  puts "-- connection #{i + 1}"
  seen.each { |l| puts l }
end
