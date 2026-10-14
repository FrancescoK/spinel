# A spawned child holds only the descriptors it is handed, as under CRuby:
# the UNIX sockets (listening, connected, accepted), the descriptors the
# scheduler opens once a thread has run, and the one an IO's close leaves
# behind are close-on-exec. Descriptors open before the program started (a
# make jobserver's) are the runner's and are left out.
require "socket"
require "tmpdir"

def open_descriptors = Dir.children("/dev/fd").map(&:to_i).sort

before = open_descriptors
path = File.join(Dir.tmpdir, "spinel_cloexec_#{Process.pid}.sock")
server = UNIXServer.new(path)
client = UNIXSocket.new(path)
accepted = server.accept
Thread.new { sleep 0.01 }.join
reader, writer = IO.pipe
reader.close
candidates = open_descriptors - before - [writer.fileno]
script = 'for fd in "$@"; do if [ -e "/dev/fd/$fd" ]; then printf "%s " "$fd"; fi; done'
out_reader, out_writer = IO.pipe
pid = Process.spawn("sh", "-c", script, "sh", *candidates.map(&:to_s), out: out_writer)
out_writer.close
Process.wait(pid)
inherited = out_reader.read.split
puts "inherited: #{inherited.empty? ? "none" : inherited.size}"
[server, client, accepted, writer, out_reader].each(&:close)
File.delete(path)
