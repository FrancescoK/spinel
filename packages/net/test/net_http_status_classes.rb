# A response is an instance of CRuby's class for its status code for the
# codes an API client names (202, 304, 307, 308, 405, 409, 410, 422, 429,
# 502, 503, 504), as for the ones already here; a code with no class of its
# own is still its family's, and the new classes raise from #value as their
# family does.
require "net/http"

STATUSES = ["200 OK", "202 Accepted", "304 Not Modified",
            "307 Temporary Redirect", "308 Permanent Redirect", "404 Not Found",
            "405 Method Not Allowed", "409 Conflict", "410 Gone",
            "418 I'm a teapot", "422 Unprocessable Entity", "429 Too Many Requests",
            "502 Bad Gateway", "503 Service Unavailable", "504 Gateway Timeout",
            "599 Network Connect Timeout"]

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

def family(res)
  return "success" if res.is_a?(Net::HTTPSuccess)
  return "redirection" if res.is_a?(Net::HTTPRedirection)
  return "client error" if res.is_a?(Net::HTTPClientError)
  return "server error" if res.is_a?(Net::HTTPServerError)
  "other"
end

def run(port)
  http = Net::HTTP.new("127.0.0.1", port)
  STATUSES.each do |status|
    res = http.request(Net::HTTP::Get.new("/"))
    raised = begin
      res.value
      "-"
    rescue Net::ProtocolError => e
      e.class.to_s
    end
    puts "#{res.code} #{res.class} (#{family(res)}) value: #{raised}"
  end
end

run(port)
t.join
