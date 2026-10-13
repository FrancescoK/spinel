# A compact path under a builtin class, written inside a module, keeps its
# leaf as its name. A class of the same leaf elsewhere makes the compiler
# qualify it, and then a read of String::Helper reaches the other Helper.
# The compiler refuses the program.
# spinel: reject-compact-path: is not supported beside another definition of Helper
module Formatting
  class String::Helper
    def call = "string helper"
  end
end

class Array::Helper
  def call = "array helper"
end

puts String::Helper.new.call
puts Array::Helper.new.call
