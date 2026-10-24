# spinel: reject-subclass: a method defined in an instance_eval block
# The receiver names an object, not a class: Two::Item is a value
# constant, and One::Item, a class of the same leaf, is another constant.
# The def would land on One::Item's singleton class or nowhere, so the
# call is refused rather than answered from the wrong class.
module One
  class Item; end
end
module Two
  Item = Object.new
end
Two::Item.instance_eval { def tag = :object }
p Two::Item.tag
