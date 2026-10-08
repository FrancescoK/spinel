# HTTPResponse#value answers nil for a 2xx and raises otherwise, as CRuby's
# does: a 3xx raises HTTPRetriableError, a 4xx HTTPClientException and a 5xx
# HTTPFatalError, with the code and the quoted reason as the message and the
# response as #response. The errors sit under Net::ProtocolError.
require "net/http"

STATUSES = ["200 OK", "204 No Content", "302 Found", "404 Not Found",
            "422 Unprocessable Entity", "500 Internal Server Error",
            "503 Service Unavailable"]

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  STATUSES.each do |status|
    c = server.accept
    while (line = c.gets)
      break if line.strip.empty?
    end
    c.write("HTTP/1.1 #{status}\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
    c.close
  end
end

def check(port)
  res = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/"))
  begin
    p [res.code, res.value]
  rescue Net::HTTPRetriableError => e3
    p [res.code, e3.class, e3.message, e3.response.equal?(res)]
  rescue Net::HTTPClientException => e4
    p [res.code, e4.class, e4.message, e4.response.equal?(res)]
  rescue Net::HTTPFatalError => e5
    p [res.code, e5.class, e5.message, e5.response.equal?(res)]
  end
  begin
    res.value
  rescue Net::ProtocolError => e
    p [e.is_a?(Net::ProtocolError), e.is_a?(StandardError)]
  end
end

def run(port)
  STATUSES.size.times { check(port) }
end

run(port)
t.join
