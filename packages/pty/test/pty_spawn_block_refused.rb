# spinel: not-cruby -- CRuby runs the block and answers nil; this package raises NotImplementedError instead (see pty.rb).
# PTY.spawn with a block raises NotImplementedError before anything is
# opened or started, so a program that relies on the block is told rather
# than having its block silently skipped.
require "pty"

def open_fds = Dir.children("/dev/fd").size

before = open_fds
ran = false
begin
  PTY.spawn("echo", "never") { |_r, _w, _pid| ran = true }
rescue NotImplementedError => e
  p e.class
end
p ran
p open_fds == before
