# PTY.spawn leaves nothing open when it fails, and answers its other forms
# as CRuby's ext/pty does.
#
# What is pinned: a spawn that raises (a command that is no String, a
# command that does not exist) leaves the descriptor count as it was, so the
# master and its writer are closed on the way out; no command runs the login
# shell ($SHELL); an env PATH is the one searched. The block form is
# pty_spawn_block_refused.rb.
require "pty"

def open_fds = Dir.children("/dev/fd").size

def drain(reader)
  out = ""
  begin
    loop { out = out + reader.readpartial(1024) }
  rescue Errno::EIO, EOFError
    nil
  end
  out.delete("\r")
end

[[42], ["no-such-command-for-pty-spawn"], [{ "PATH" => "/nonexistent" }, "echo"]].each do |args|
  before = open_fds
  begin
    PTY.spawn(*args)
  rescue TypeError, SystemCallError => e
    p e.class
  end
  p open_fds == before
end

ENV["SHELL"] = "/bin/echo"
reader, _writer, pid = PTY.spawn
p drain(reader)
Process.waitpid2(pid)

reader, _writer, pid = PTY.spawn({ "PATH" => "/nonexistent:/bin:/usr/bin" }, "echo", "on PATH")
print drain(reader)
Process.waitpid2(pid)

