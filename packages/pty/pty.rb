# Spinel bundled `pty` -- a carried-C spin package (Path B).
#
# PTY.spawn runs a command on a new pseudo-terminal, as CRuby's ext/pty does:
#
#   reader, writer, pid = PTY.spawn([env,] command..., chdir: nil)
#
# The child is a session leader with the terminal's slave as its controlling
# terminal and as stdin, stdout and stderr. `reader` and `writer` are the
# master, on two descriptors, both close-on-exec. `env` is laid over the
# current environment as for Process.spawn (a nil value unsets the name), and
# one String with a shell character runs through /bin/sh -c. A command that
# cannot be executed raises its Errno at the call (Errno::ENOENT), and so does
# a chdir: directory the child cannot enter. Reading the
# master after the child has gone raises Errno::EIO on Linux, as under CRuby.
#
# No command runs the login shell ($SHELL, else the password entry's), as
# in CRuby. The block form raises NotImplementedError: CRuby answers nil after
# the block, and an answer that is an Array or nil would make every caller's
# reader and writer boxed values that lose IO methods only a typed IO has
# (close_on_exec?, winsize=). What is absent is absent the way a subset is:
# PTY.open, PTY.check and PTY.getpty are not here, so a program that calls
# them does not compile. The terminal's size is IO#winsize= on the master
# (`require "io/console"`).
module PTY
  module Native
    native_lib "pty"
    native_obj "packages/pty/sp_pty.o"
    native_func :open_master, [],                      :int, "sp_pty_open_master"
    native_func :dup_fd,      [:int],                  :int, "sp_pty_dup"
    native_func :spawn_child, [:int, :int, :any, :any, :any], :int, "sp_pty_spawn_child"
  end

  def self.spawn(*args, chdir: nil)
    env = nil
    env = args.shift if args[0].is_a?(Hash)
    raise NotImplementedError, "PTY.spawn with a block is not supported; call it without one and Process.detach the pid" if block_given?
    # Each native call closes the descriptors it is handed if it raises, and
    # the writer exists before the child does: a failed spawn leaves nothing
    # open and no child behind.
    master = Native.open_master
    writer_fd = Native.dup_fd(master)
    pid = Native.spawn_child(master, writer_fd, env, args, chdir)
    reader = IO.new(master, "r")
    writer = IO.new(writer_fd, "w")
    writer.sync = true
    [reader, writer, pid]
  end
end
