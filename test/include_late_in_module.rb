# A module a reopening of another module includes, after a method that
# calls the included module's method on a receiver of unknown class: a
# class including the outer module answers with the inner module's method
# once the include has run, as in CRuby (Rails' ActionView::Helpers
# includes its helper modules in a reopening, after their files loaded).
module TagHelper
  def tag(name) = "<#{name}>"
end
module Helpers
  def helper? = true
end
class View
  include Helpers
end
class Coder
  def tag = "!coder"
end
def tag_of(coder) = coder.tag
p tag_of(Coder.new)
module Helpers
  include TagHelper
end
p tag_of(Coder.new), View.new.tag("p"), View.new.helper?
