# PTY.spawn: a child on a new pseudo-terminal, as CRuby's ext/pty answers it.
#
# What is pinned: the child sees a terminal (tty), the env Hash sets and
# unsets names, typed input reaches it, the master reads Errno::EIO once the
# child has gone, one String with a shell character runs through the shell,
# the reader and writer are two close-on-exec descriptors, and a command that
# does not exist raises Errno::ENOENT at the call.
require "pty"

def drain(reader)
  out = ""
  begin
    loop { out = out + reader.readpartial(1024) }
  rescue Errno::EIO, EOFError
    nil
  end
  out.delete("\r")
end

# Read until `marker` has arrived, so input is written only once the child is
# waiting for it (the terminal echoes input as it arrives).
def read_until(reader, marker)
  out = ""
  out = out + reader.readpartial(1024) until out.delete("\r").include?(marker)
  out.delete("\r")
end

reader, writer, pid = PTY.spawn(
  { "PTY_SET" => "yes", "HOME" => nil },
  "sh", "-c", 'echo "set=$PTY_SET home=${HOME-unset}"; tty >/dev/null && echo tty; read line; echo "got=$line"'
)
print read_until(reader, "tty\n")
# The writer is synchronous: even input without a newline reaches the terminal.
writer.write("hello")
print read_until(reader, "hello")
writer.write("\n")
print drain(reader)
_, status = Process.waitpid2(pid)
p status.exitstatus
p [reader.fileno == writer.fileno, reader.close_on_exec?, writer.close_on_exec?, writer.sync]

reader, _writer, pid = PTY.spawn("echo one && echo two")
print drain(reader)
Process.waitpid2(pid)

begin
  PTY.spawn("no-such-command-for-pty-spawn")
rescue SystemCallError => e
  p e.class
end

# The master read from another thread while this one writes: how a program
# that relays a terminal (a web terminal) uses it.
# Read both lines before replying: one write does not guarantee both echoes
# precede the child's first reply. Drain through EOF/EIO before waiting.
reader, writer, pid = PTY.spawn("sh", "-c", "read a; read b; echo \"first=$a\"; echo \"second=$b\"")
relay = Thread.new { drain(reader) }
writer.write("1\n2\n")
print relay.value
Process.waitpid2(pid)
