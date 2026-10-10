# Not on macOS: its /dev/ptmx answers ENOTTY to TIOCSWINSZ, so the pty part
# runs on Linux only and prints the same line on every platform.
require "io/console"

r, w = IO.pipe
f = File.open(__FILE__)
p [r.respond_to?(:winsize), r.respond_to?(:winsize=)]
p [f.respond_to?(:winsize), f.respond_to?(:winsize=)]
p [$stdout.respond_to?(:winsize), $stdout.respond_to?(:winsize=)]
p %i[winsize winsize= nope].map { |m| w.respond_to?(m) }
x = [r, 1][0]
p [x.respond_to?(:winsize), x.respond_to?(:winsize=)]
st = File.stat(__FILE__)
p [st.respond_to?(:winsize), st.respond_to?(:winsize=)]
f.close
r.close
w.close

ok = true
if RUBY_PLATFORM.include?("linux")
  File.open("/dev/ptmx", "r+") do |m|
    opener = ->(io) { io }
    boxed = opener.call(m)
    ok &&= boxed.respond_to?(:winsize=)
    boxed.winsize = [30, 100] if boxed.respond_to?(:winsize=)
    ok &&= m.winsize == [30, 100]
  end
end
p ok
