# PTY.spawn with chdir: starts the child in that directory, as CRuby does,
# with or without an env Hash and through the shell. A directory the child
# cannot enter raises Errno::ENOENT and leaves nothing open; any other option
# is an ArgumentError, not an argument to the command.
require "pty"
require "tmpdir"

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

def run(*args, **opts)
  reader, writer, pid = PTY.spawn(*args, **opts)
  out = drain(reader)
  Process.waitpid2(pid)
  reader.close
  writer.close
  out
end

Dir.mktmpdir("pty_spawn_chdir") do |dir|
  real = File.realpath(dir)
  p run("pwd", chdir: dir).chomp == real
  p run({ "PTY_CHDIR" => "env" }, "sh", "-c", "pwd; echo $PTY_CHDIR", chdir: dir).lines.map(&:chomp) == [real, "env"]
  p run("pwd && true", chdir: dir).chomp == real
  p run("pwd").chomp == File.realpath(Dir.pwd)

  before = open_fds
  begin
    run("pwd", chdir: File.join(dir, "missing"))
  rescue SystemCallError => e
    p e.class
  end
  p open_fds == before
end

begin
  run("pwd", unknown_option: 1)
rescue ArgumentError => e
  p e.class
end
