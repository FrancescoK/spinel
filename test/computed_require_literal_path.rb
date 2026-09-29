# A require whose name is computed from literals that spell a path under the
# requiring file's own directory (the Mr Bones gem layout) loads that file; a
# %w(...).each loop around it is unrolled.
module CRLP
  LIBPATH = __dir__ + "/"
  def self.libpath(*args) = File.join(LIBPATH, *args)
end
require File.join(CRLP::LIBPATH, "computed_require_literal_path", "one")
%w(two three).each do |f|
  require CRLP.libpath(["computed_require_literal_path", f])
end
p [CRLP.one, CRLP.two, CRLP.three]
raise "line numbers moved" unless __LINE__ == 13
# a modifier stays with its call, which is not rewritten
require File.join(CRLP::LIBPATH, "computed_require_literal_path", "missing") if false
%w(four five).each do |f|
  require CRLP.libpath(["computed_require_literal_path", f])
end
p [CRLP.four, CRLP.five]
raise "line numbers moved" unless __LINE__ == 20
