# Computed requires and autoloads are calls in the file's own tree (#9898):
# the same text in a heredoc is text. The line rewriter took a heredoc line
# for a computed require, and the autoload lexer, which knew no heredocs,
# rewrote an autoload in one; each rewrote the String.
$LOAD_PATH.unshift __dir__, File.join(__dir__, "require_rewrites_tree")
text = <<~DOC
  autoload :Foo, "require_rewrites_tree/foo"
DOC
puts text
puts <<~T
  require File.join("require_rewrites_tree", "b")
T
autoload :Foo, File.expand_path("require_rewrites_tree/foo", __dir__)
p Foo::NAME
# Words past a loop's lines (the brace form's second) are hoisted ahead of
# the loop's statement, not into the method or class body around it.
def rr_load
  %w(lg lh).each { |v| require File.join("require_rewrites_tree", v) }
end
rr_load
p [LG, LH]
class RrK
  %w(kg kh).each { |v| require File.join("require_rewrites_tree", v) }
end
p [KG, KH]
# each_with_index, and a loop that is the receiver of a call, unroll too.
%w(ig ih).each_with_index do |v, i|
  require File.join("require_rewrites_tree", v)
end
p [IG, IH]
%w(o1 o2 o3 o4).each do |f|
  require File.join("require_rewrites_tree", f) # c
end.size
p [O1, O2, O3, O4]
# A brace loop unrolls whatever braces follow it in the file.
%w[j1 j2].each { |v| require File.join("require_rewrites_tree", v) }
p({ j: [J1, J2] })
# An autoload with a modifier keeps the blank before it.
require_relative "require_rewrites_tree/r"
p RrR::A6::V
