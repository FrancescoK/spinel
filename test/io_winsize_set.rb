# IO#winsize= (io/console): [rows, cols] or [rows, cols, xpixel, ypixel] through
# TIOCSWINSZ, answering its argument; any other length is ArgumentError, and a
# handle that is not a terminal raises the ioctl's Errno, as CRuby does.
#
# A Linux pty master is a terminal, so /dev/ptmx gives the size a real place
# to land without a controlling terminal or the pty library; the size set on
# the master is what #winsize then reads back. macOS's /dev/ptmx answers ENOTTY
# to TIOCSWINSZ, so that half runs on Linux only and prints the same single
# line everywhere: whether every answer was the expected one.
require "io/console"

r, _w = IO.pipe
begin
  r.winsize = [24, 80]
rescue SystemCallError => e
  p e.class
end

ok = true
if RUBY_PLATFORM.include?("linux")
  File.open("/dev/ptmx", "r+") do |m|
    ok &&= (m.winsize = [30, 100]) == [30, 100]
    ok &&= m.winsize == [30, 100]
    ok &&= (m.winsize = [40, 120, 0, 0]) == [40, 120, 0, 0]
    ok &&= m.winsize == [40, 120]
    begin
      m.winsize = [1]
      ok = false
    rescue ArgumentError => e
      ok &&= e.message == "wrong number of arguments (given 1, expected 2 or 4)"
    end
  end
end
p ok
