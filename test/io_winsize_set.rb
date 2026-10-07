# IO#winsize= (io/console): [rows, cols] or [rows, cols, xpixel, ypixel] through
# TIOCSWINSZ, answering its argument; any other length is ArgumentError, and a
# handle that is not a terminal raises the ioctl's Errno, as CRuby does.
#
# A Linux pty master is a terminal, so /dev/ptmx gives the size a real place
# to land without a controlling terminal or the pty library; the size set on
# the master is what #winsize then reads back. macOS's /dev/ptmx answers
# ENOTTY to TIOCSWINSZ, so the pty half runs on Linux only.
require "io/console"

r, _w = IO.pipe
begin
  r.winsize = [24, 80]
rescue SystemCallError => e
  p e.class
end

if RUBY_PLATFORM.include?("linux")
File.open("/dev/ptmx", "r+") do |m|
  p(m.winsize = [30, 100])
  p m.winsize
  p(m.winsize = [40, 120, 0, 0])
  p m.winsize
  begin
    m.winsize = [1]
  rescue ArgumentError => e
    p e.message
  end
end
end
