def where(n) = n > 5 ? 42 : "/tmp"

def command(session, n)
  cwd = where(n)
  cmd = [ "tmux", "new-session", "-s", session ]
  cmd += [ "-c", cwd ] if cwd
  cmd
end

p command("one", 1)
p command("two", 9)
