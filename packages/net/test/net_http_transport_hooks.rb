# A Net::HTTP subclass can follow its connection through CRuby's private
# transport hooks: `connect` opens the socket, `begin_transport(req)` runs
# before each request is written and connects again when the previous one
# was closed. A module included into the subclass overrides both and calls
# super, which is how a connection pool tells a dead idle connection from a
# request the server may already have. keep_alive_timeout reads back what
# was written.
require "net/http"

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  3.times do |i|
    c = server.accept
    while (line = c.gets)
      break if line.strip.empty?
    end
    c.write("HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nr#{i}")
    c.close
  end
end

LOG = []

module Stages
  attr_reader :stage

  private
    def begin_transport(req)
      LOG << "begin #{req.method}"
      @stage = :checking
      super.tap { @stage = :sent }
    end

    def connect
      LOG << "connect"
      @stage = :connecting if @stage == :checking
      super
    end
end

class TracedHTTP < Net::HTTP
  include Stages
end

def run(port)
  http = TracedHTTP.new("127.0.0.1", port)
  http.keep_alive_timeout = 30
  p http.keep_alive_timeout
  http.start
  p [http.get("/").body, http.stage]
  p [http.get("/").body, http.stage]
  http.finish

  p [TracedHTTP.new("127.0.0.1", port).request(Net::HTTP::Get.new("/")).body]
  p LOG
end

run(port)
t.join
