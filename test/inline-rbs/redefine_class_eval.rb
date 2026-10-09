# As redefine_unannotated.rb, with the unannotated replacement written in a
# class_eval block.
class K
  #: (String) -> String
  def m(x) = x
end

K.class_eval do
  def m(x) = x
end

p K.new.m(1)
