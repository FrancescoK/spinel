# A setter Symbol as the block of a builtin iterator: its proc calls `v=`
# with what the block is given, which is not lowered, so the call is
# refused rather than answered with a NoMethodError for `each` (CRuby
# raises ArgumentError: each yields one argument, `v=` takes one more).
class S; attr_accessor :v; end
p [S.new].each(&:v=).size
