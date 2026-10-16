# spinel: share
# `super` from a method no other class of the program defines reaches the
# builtin, which answers what it answers on self (Object#freeze answers
# self): the class facts counted the method itself as one of its name's
# others, so the builtin's answer never joined, and a boxed call on the
# value had no arm for the class it is (NoMethodError).
class Other
  def tag = "other"
end
class Box
  def freeze
    super
  end
  def tag = "box"
end
[Other.new, Box.new.freeze].each { |o| puts o.tag }
