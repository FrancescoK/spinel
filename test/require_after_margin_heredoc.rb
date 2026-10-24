# A require nested below a heredoc whose terminator stands at the margin:
# walking up to the statement the require sits in, the splice took the
# terminator for the nearest statement start and put the library ahead of
# it, into the String (optparse's COMPSYS_HEADER held pp.rb, and
# OptionParser#compsys printed its source).
class Gen
  HEADER = <<'XXX'

typeset -A opt_args
_arguments -s -S \
XXX

  def load_lib
    require_relative "require_heredoc/lib"
    HdLib.v
  end
end

print Gen::HEADER
p Gen.new.load_lib
p Gen::HEADER.lines.size
