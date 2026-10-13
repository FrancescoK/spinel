# A class named String in another namespace is not the builtin: a bare
# method_defined? in its body answers for the class, as in CRuby.
module Shapes
  class String
    def label = "shape"
    p method_defined?(:label), method_defined?(:upcase)
  end
end

module Text; end
class Text::String
  def body = "text"
  p method_defined?(:body)
end
