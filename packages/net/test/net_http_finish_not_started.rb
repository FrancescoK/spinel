# Net::HTTP#finish on a session that is not open raises IOError, as CRuby's
# does: before any start, a second time, and after a block form of start or
# a #request that opened its own session. The package's own teardown stays
# silent: Net::HTTP.start's block may finish the session itself (#7976).
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

def try_finish(label, http)
  http.finish
  puts "#{label}: finished"
rescue IOError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

def run(port)
  try_finish("never started", Net::HTTP.new("127.0.0.1", port))

  http = Net::HTTP.new("127.0.0.1", port)
  http.start
  p http.get("/").body
  try_finish("open", http)
  try_finish("again", http)

  http = Net::HTTP.new("127.0.0.1", port)
  http.start { |s| :done }
  try_finish("after a block", http)

  http = Net::HTTP.new("127.0.0.1", port)
  p http.get("/").body
  p http.started?
  try_finish("after a request on its own", http)

  p Net::HTTP.start("127.0.0.1", port) { |s| b = s.get("/").body; s.finish; b }
  p Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/")).body
end

run(port)
t.join
