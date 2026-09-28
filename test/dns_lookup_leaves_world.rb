# DNS lookups run outside the world, so GCs can happen during them.
# Threads resolve "localhost" while others allocate; what each lookup
# thread holds across the call must survive.
require "socket"

srv = TCPServer.new("localhost", 0)
port = srv.addr[1]

lookups = (0...6).map do |w|
  Thread.new(w) do |id|
    ok = 0
    20.times do |k|
      held = ["w#{id}-#{k}" * 3, k]
      case k % 3
      when 0 then ok += 1 unless Socket.getaddrinfo("localhost", port).empty?
      when 1 then ok += 1 if Socket.pack_sockaddr_in(port, "localhost").size > 0
      when 2
        u = UDPSocket.new
        u.connect("localhost", port)
        u.close
        ok += 1
      end
      raise "lost #{id}/#{k}" unless held[0] == "w#{id}-#{k}" * 3 && held[1] == k
    end
    ok
  end
end
churn = (0...4).map do
  Thread.new { n = 0; 3000.times { |k| n += ("c" * (k % 40 + 1)).length; [k, k.to_s] }; n }
end

p lookups.map(&:value)
churn.each(&:join)
# TCPSocket.new resolves too. It connects here, alone, because concurrent
# connects hit an unrelated ECONNREFUSED.
c = TCPSocket.new("localhost", port)
srv.accept.close
c.close
srv.close
puts "done"
