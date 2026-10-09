# As redefine_unannotated.rb, with the unannotated replacement in a second
# file, so the definitions are in different files of one program.
class K
  #: (String) -> String
  def m(x) = x
end

require_relative "redefine_unannotated_part"

p K.new.m(1)
