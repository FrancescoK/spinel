# The response half as CRuby reads it: a header sent twice is one value
# through #[] (joined with ", ") and its separate values through
# #get_fields, which answers nil for an absent one; http_version is the
# number alone; a status line that is not one raises Net::HTTPBadResponse,
# which is not a Net::ProtocolError. set_debug_output traces the session.
# The last of several Transfer-Encoding values says whether the body is
# chunked, and repeated Content-Length values stay separate.
require "net/http"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
replies = [
  "HTTP/1.1 200 OK\r\nSet-Cookie: a=1; path=/\r\nSet-Cookie: b=2\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok",
  "SMTP/1.0 hello\r\nContent-Length: 0\r\n\r\n",
  "HTTP/1.0 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n",
  "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nhi",
  "HTTP/1.1 200 OK\r\nTransfer-Encoding: x-custom\r\nTransfer-Encoding: chunked\r\nConnection: close\r\n\r\n2\r\nok\r\n0\r\n\r\n",
  "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok",
]
t = Thread.new do
  replies.each do |reply|
    c = server.accept
    while (line = c.gets)
      break if line.strip.empty?
    end
    c.write(reply)
    c.close
  end
end

def run(port)
  res = Net::HTTP.new("127.0.0.1", port).get("/")
  p res["set-cookie"]
  p res.get_fields("Set-Cookie")
  p res.get_fields("X-Absent")
  p res.http_version

  begin
    Net::HTTP.new("127.0.0.1", port).get("/")
  rescue Net::HTTPBadResponse => e
    p [e.class, e.message]
  end
  p Net::HTTPBadResponse.ancestors.include?(Net::ProtocolError)
  p Net::HTTPBadResponse.superclass

  res = Net::HTTP.new("127.0.0.1", port).get("/")
  p [res.http_version, res.code, res.message]

  trace = String.new
  http = Net::HTTP.new("127.0.0.1", port)
  http.set_debug_output(trace)
  p http.get("/").body
  lines = trace.lines
  p lines[0].sub(/:\d+/, ":PORT")
  p lines[1]
  p lines.any? { |l| l.start_with?("<- \"GET / HTTP/1.1\\r\\n") }
  p lines.include?("-> \"HTTP/1.1 200 OK\\r\\n\"\n")
  p lines.last

  res = Net::HTTP.new("127.0.0.1", port).get("/")
  p [res.body, res.get_fields("Transfer-Encoding")]
  res = Net::HTTP.new("127.0.0.1", port).get("/")
  p [res.body, res.get_fields("Content-Length")]
end

run(port)
t.join
