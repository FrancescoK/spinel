# Net::SMTP against a server in this same program, so the test needs no
# network. The server keeps what it reads and the test prints it after the
# join: the EHLO and its capabilities, MAIL and RCPT for each recipient, the
# message as it goes over DATA (line endings made CRLF, a leading dot
# doubled), open_message_stream, start without a block, and the HELO retry
# when a server refuses EHLO.
require "net/smtp"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]

# One profile per connection, in the order the client opens them.
profiles = [:esmtp, :esmtp, :esmtp, :no_ehlo]

t = Thread.new do
  transcripts = []
  profiles.each do |profile|
    c = server.accept
    seen = []
    c.write "220 fake ESMTP ready\r\n"
    in_data = false
    while (line = c.gets)
      if in_data
        if line == ".\r\n"
          in_data = false
          c.write "250 2.0.0 queued\r\n"
        else
          seen << "  | #{line.inspect}"
        end
        next
      end
      seen << line.chomp
      case line
      when /\AEHLO/
        if profile == :no_ehlo
          c.write "502 5.5.2 EHLO not recognized\r\n"
        else
          c.write "250-fake.example\r\n250-8BITMIME\r\n250-SIZE 1000\r\n250 AUTH PLAIN LOGIN\r\n"
        end
      when /\AHELO/ then c.write "250 fake.example\r\n"
      when /\AMAIL/, /\ARCPT/ then c.write "250 2.1.0 ok\r\n"
      when /\ADATA/
        in_data = true
        c.write "354 go ahead\r\n"
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

# send_message with a block: the response, then what the session knew.
Net::SMTP.start("127.0.0.1", port, "client.example", tls: false, starttls: false) do |smtp|
  p smtp.started?
  p smtp.capable?("8BITMIME")
  p smtp.capable?("SIZE")
  p smtp.capable_auth_types
  p smtp.capable_cram_md5_auth?
  res = smtp.send_message("Subject: hi\nTo: b@example.com\n\nbody\n.leading dot\n", "a@example.com",
                          "b@example.com", "c@example.com")
  p res.class, res.status, res.string, res.success?
end

# open_message_stream: puts, print, write and << all land in the message.
Net::SMTP.start("127.0.0.1", port, "client.example", tls: false, starttls: false) do |smtp|
  res = smtp.open_message_stream("a@example.com", ["d@example.com"]) do |f|
    f.puts "Subject: stream"
    f.puts
    f.print "one line\n"
    f.write "two\r\n"
    f << "three" << "\n"
  end
  p res.status
end

# start without a block hands back the session; finish ends it.
smtp = Net::SMTP.new("127.0.0.1", port)
smtp.disable_starttls
p smtp.started?
smtp.start(helo: "client.example")
p smtp.started?
p smtp.send_mail("x\n", "a@example.com", "e@example.com").status
smtp.finish
p smtp.started?

# A server that refuses EHLO gets HELO, and the session goes on without
# the extensions.
Net::SMTP.start("127.0.0.1", port, "client.example", tls: false, starttls: false) do |smtp|
  p smtp.capable?("8BITMIME")
  p smtp.send_message("y\n", "a@example.com", "f@example.com").status
end

t.value.each_with_index do |seen, i|
  puts "-- connection #{i + 1}"
  seen.each { |l| puts l }
end
p Net::SMTP.default_port
