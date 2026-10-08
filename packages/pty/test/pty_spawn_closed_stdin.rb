# PTY.spawn in a program that closed its stdin: the master must not take
# descriptor 0, or the child's dup2 of the terminal onto 0 replaces it and
# the child starts without its terminal as stdin.
require "pty"

def read_until(reader, marker)
  out = ""
  out = out + reader.readpartial(1024) until out.delete("\r").include?(marker)
  out.delete("\r")
end

IO.new(0).close   # descriptor 0 itself, as a daemonized program has it
reader, writer, pid = PTY.spawn("sh", "-c", "echo ready; read line; echo got=$line")
print read_until(reader, "ready\n")
writer.write("hi\n")
print read_until(reader, "got=hi\n")
_, status = Process.waitpid2(pid)
p status.exitstatus
p [reader.fileno > 2, writer.fileno > 2]
