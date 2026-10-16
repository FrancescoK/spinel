# While a backtick command runs, its pipe is open in the program. A child
# that another thread starts in that time sees none of it: the runtime
# creates the pipe close-on-exec, as CRuby does.
require "tmpdir"

def open_descriptors = Dir.children("/dev/fd").map(&:to_i).sort

before = open_descriptors
marker = File.join(Dir.tmpdir, "spinel_backtick_cloexec_#{Process.pid}")
reader = Thread.new { `touch #{marker}; sleep 1; echo done` }
500.times do
  break if File.exist?(marker)
  sleep 0.01
end
fresh = open_descriptors - before
script = 'for fd in "$@"; do if [ -e "/dev/fd/$fd" ]; then printf "%s " "$fd"; fi; done; echo'
seen = IO.popen(["sh", "-c", script, "sh", *fresh.map(&:to_s)], &:read).split
puts "command started: #{File.exist?(marker)}"
puts "inherited: #{seen.empty? ? "none" : seen.size}"
p reader.value
File.delete(marker)
