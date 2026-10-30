# A program that pins the address it connects to reopens Net::HTTP the way
# CRuby's internals allow: `start` redefined around the private do_start and
# do_finish, and the private conn_address redefined to answer an address of
# its own while `address` stays the name for Host. The connection goes where
# conn_address says, and Timeout comes with net/http, as it does in CRuby.
require "net/http"

module Net
  class HTTP
    attr_accessor :address, :custom_conn_address

    def start
      if block_given?
        begin
          do_start
          return yield(self)
        ensure
          do_finish
        end
      end
      do_start
      self
    end

    private

    def conn_address
      if custom_conn_address.to_s != ""
        custom_conn_address
      else
        address
      end
    end
  end
end

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]
t = Thread.new do
  2.times do
    c = server.accept
    host = ""
    while (line = c.gets)
      break if line.strip.empty?
      host = line.strip.sub(/:\d+\z/, "") if line.downcase.start_with?("host:")
    end
    c.write("HTTP/1.1 200 OK\r\nContent-Length: #{host.bytesize}\r\nConnection: close\r\n\r\n#{host}")
    c.close
  end
end

def run(port)
  http = Net::HTTP.new("pinned.example", port)
  http.custom_conn_address = "127.0.0.1"
  p http.get("/").body
  p http.started?

  http = Net::HTTP.new("127.0.0.1", port)
  http.address = "renamed.example"
  http.custom_conn_address = "127.0.0.1"
  res = Timeout.timeout(5) { http.request(Net::HTTP::Get.new("/")) }
  p res.body
  p Net::ReadTimeout.ancestors.include?(Timeout::Error)
end

run(port)
t.join
