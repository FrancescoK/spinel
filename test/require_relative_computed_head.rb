# A require_relative whose argument is an operator on something other than a
# string literal is a computed path, a call at run time like any other. Only
# an operator on a literal (`"a" + ""`, test/reject) is refused (#10146).
# None of these methods is called.
def computed_heads(base)
  require_relative File.dirname(__FILE__) + "/require_rewrites_tree/foo"
  require_relative base + "/foo"
  require_relative File.dirname(__FILE__) + "/x" + "y"
end

puts "main"
