# Class values in a box: the switch over class methods answers Custom with
# its own `self.superclass`, but FromAnon would still reach the builtin,
# which has no class object for its anonymous superclass.
class FromAnon < Struct.new(:a)
end

class Custom
  def self.superclass
    "custom-super"
  end
end

[FromAnon, Custom].each { |k| p k.superclass }
