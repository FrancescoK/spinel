# io/console's IO#raw { } and IO#noecho { }: on a terminal the mode is set
# for the block and the settings restored however it ends, and the block's
# value is the call's (checked under a pseudo-terminal by hand; the test
# harness has none). On anything else the mode cannot be read: CRuby raises
# the OS's errno (Errno::ENOTTY on Linux, Errno::ENODEV for macOS's
# /dev/null) and the block does not run.
require "io/console"

def not_a_tty?(e) = e.is_a?(Errno::ENOTTY) || e.is_a?(Errno::ENODEV)

File.open(File::NULL) do |f|
  ran = false
  begin
    f.raw { ran = true }
  rescue SystemCallError => e
    p [not_a_tty?(e), ran]
  end
  begin
    f.noecho { |io| ran = io }
  rescue SystemCallError => e
    p [not_a_tty?(e), ran]
  end
end

# A program class with its own raw (tty-reader's Mode#raw) keeps it, also on
# a value that may be either that class or an IO.
class Mode
  def raw(is_on = true)
    "mode raw #{is_on} #{yield}"
  end
end
def pick(i) = i.zero? ? Mode.new : File.open(File::NULL)
p pick(0).raw { 1 }
begin
  pick(1).raw { 2 }
rescue SystemCallError => e
  p not_a_tty?(e)
end
