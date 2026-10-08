# put, patch and delete send the body and headers given, as in CRuby. An
# empty PATCH still sends Content-Length: 0, and delete sends Depth: Infinity
# unless headers are given.
require "net/http"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  7.times do
    c = server.accept
    first = c.gets.to_s.strip
    len = nil
    seen = []
    while (line = c.gets)
      break if line.strip.empty?
      name, value = line.split(":", 2)
      n = name.downcase
      len = value.strip.to_i if n == "content-length"
      seen << "#{n}=#{value.strip}" if n == "content-length" || n == "content-type" || n == "depth" || n == "x-a"
    end
    # Reading zero bytes from an idle socket blocks in Spinel for now.
    body = len.nil? || len.zero? ? "" : c.read(len)
    out = "#{first} #{seen.sort.join(" ")} body=#{body}"
    c.write("HTTP/1.1 200 OK\r\nContent-Length: #{out.bytesize}\r\nConnection: close\r\n\r\n#{out}")
    c.close
  end
end

def run(port)
  req = Net::HTTP::Patch.new("/r")
  p [req.method, req.path, req.is_a?(Net::HTTPRequest)]

  http = Net::HTTP.new("127.0.0.1", port)
  res = http.put("/u", "x")
  p [res.class, res.body]
  p http.put("/u", "{}", { "Content-Type" => "application/json" }).body
  p http.patch("/p", "{\"a\":1}", { "Content-Type" => "application/json" }).body
  p http.patch("/p", "").body
  p http.delete("/d").body
  p http.delete("/d", { "X-A" => "1" }).body

  req = Net::HTTP::Patch.new("/q", "Content-Type" => "text/plain")
  req.body = "hi"
  p http.request(req).body
end

run(port)
t.join
