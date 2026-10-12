require_relative "hello_world"

server = HelloWorld.build(port: ENV.fetch("PORT", "9292").to_i)
server.config[:StartCallback] = proc do
  puts "Listening on http://127.0.0.1:#{server.config[:Port]}/"
  $stdout.flush
end
trap("INT") { server.shutdown }
trap("TERM") { server.shutdown }

begin
  server.start
ensure
  server.shutdown
end
