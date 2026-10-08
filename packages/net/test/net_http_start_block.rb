# Net::HTTP#start with a block opens the session, yields it, closes it when
# the block ends, even by an exception, and answers the block's value; the
# blockless form still answers self and leaves the session open (#7976).
require "net/http"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  5.times do |i|
    c = server.accept
    while (line = c.gets)
      break if line.strip.empty?
    end
    c.write("HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nr#{i}")
    c.close
  end
end

def run(port)
  http = Net::HTTP.new("127.0.0.1", port)
  inside = nil
  value = http.start { |s| inside = s.started?; s.get("/").body }
  p [value, inside, http.started?]

  http = Net::HTTP.new("127.0.0.1", port)
  begin
    http.start { |s| s.get("/"); raise ArgumentError, "boom" }
  rescue ArgumentError => e
    p [e.message, http.started?]
  end

  p Net::HTTP.new("127.0.0.1", port).start { |s| [s.get("/").body, s.get("/").body] }

  http = Net::HTTP.new("127.0.0.1", port)
  p http.start.equal?(http)
  p [http.started?, http.get("/").body]
  http.finish
  p http.started?
end

run(port)
t.join
