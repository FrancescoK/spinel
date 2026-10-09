# IO#winsize= on a poly-carried handle: a terminal returned through a lambda,
# read back out of an Array, or passed where call sites disagree. The typed
# arm set the size; the boxed one raised NoMethodError for a value that is
# an IO. It answers its argument, a pipe raises the ioctl's Errno, and a
# value that is not an IO raises NoMethodError after the size is evaluated.
#
# A Linux pty master is a terminal, so /dev/ptmx gives the size a place to
# land; macOS's /dev/ptmx answers ENOTTY to TIOCSWINSZ, so that half runs on
# Linux only and prints the same line everywhere.
require "io/console"

def resize(handle, size)
  handle.winsize = size
end

r, _w = IO.pipe
begin
  [r, 1][0].winsize = [24, 80]
rescue SystemCallError => e
  p e.class
end

order = []
begin
  [r, 1][1].winsize = (order << :size; [24, 80])
rescue NoMethodError
  order << :no_method
end
p order

begin
  resize(1, [24, 80])
rescue NoMethodError
  p :no_method
end

ok = true
if RUBY_PLATFORM.include?("linux")
  File.open("/dev/ptmx", "r+") do |m|
    opener = ->(io) { io }
    boxed = opener.call(m)
    ok &&= (boxed.winsize = [30, 100]) == [30, 100]
    ok &&= m.winsize == [30, 100]
    ok &&= ([m, nil][0].winsize = [40, 120, 0, 0]) == [40, 120, 0, 0]
    ok &&= m.winsize == [40, 120]
    ok &&= resize(m, [20, 60]) == [20, 60]
    ok &&= m.winsize == [20, 60]
    begin
      boxed.winsize = [1]
      ok = false
    rescue ArgumentError
    end
  end
end
p ok
