require "socket"
require "net/http"

server = TCPServer.new("127.0.0.1", 0)

begin
  Net::HTTP.start("127.0.0.1", server.addr[1],
                 open_timeout: 10, read_timeout: 20) do |http|
    p [http.open_timeout, http.read_timeout]
  end
ensure
  server.close
end
