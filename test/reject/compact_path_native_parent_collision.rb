# Two compact paths under builtin classes (String and Array here) are two
# classes in CRuby: String::Helper and Array::Helper. Spinel places both
# under the module around them, where they have one name, Helper, and become
# one class. The compiler refuses the program.
# spinel: reject-compact-path: is not supported beside another definition of Helper
module Formatting
  class String::Helper
    def call = "string helper"
  end

  class Array::Helper
    def call = "array helper"
  end
end

puts String::Helper.new.call
puts Array::Helper.new.call
