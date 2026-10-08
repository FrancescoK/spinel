# Spinel bundled `pty` -- a carried-C spin package (Path B).
#
# PTY.spawn runs a command on a new pseudo-terminal, as CRuby's ext/pty does:
#
#   reader, writer, pid = PTY.spawn([env,] command...)
#
# The child is a session leader with the terminal's slave as its controlling
# terminal and as stdin, stdout and stderr. `reader` and `writer` are the
# master, on two descriptors, both close-on-exec. `env` is laid over the
# current environment as for Process.spawn (a nil value unsets the name), and
# one String with a shell character runs through /bin/sh -c. A command that
# cannot be executed raises its Errno at the call (Errno::ENOENT). Reading the
# master after the child has gone raises Errno::EIO on Linux, as under CRuby.
#
# What is absent is absent the way a subset is: PTY.open, PTY.check, PTY.getpty
# and the block form of spawn are not here, so a program that calls them does
# not compile. The terminal's size is IO#winsize= on the master
# (`require "io/console"`).
module PTY
  module Native
    native_lib "pty"
    native_obj "packages/pty/sp_pty.o"
    native_func :open_master, [],                :int, "sp_pty_open_master"
    native_func :dup_fd,      [:int],            :int, "sp_pty_dup"
    native_func :spawn_child, [:int, :any, :any], :int, "sp_pty_spawn_child"
  end

  def self.spawn(*args)
    env = nil
    env = args.shift if args[0].is_a?(Hash)
    master = Native.open_master
    pid = Native.spawn_child(master, env, args)
    reader = IO.new(master, "r")
    writer = IO.new(Native.dup_fd(master), "w")
    writer.sync = true
    [reader, writer, pid]
  end
end
