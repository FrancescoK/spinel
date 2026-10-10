# spinel: gc-minor
# The value of instance_variable_set into an ivar whose String is shared (an
# alias is taken, then the String is changed in place) is the String it
# stored. The slot holds a handle where a plain String slot holds the bytes,
# and the call's value read the handle as bytes: puts printed unprintable
# characters and a concatenation or a method call on it did not compile.
class K
  def initialize
    @text = +"i"
    keep = @text
    @text << "!"
  end
  def text = @text
  def bump = @text << "+"
end

k = K.new
puts(k.instance_variable_set(:@text, +"v"))
k.bump
p k.text
puts "<" + k.instance_variable_set(:@text, "lit") + ">"
p k.instance_variable_set(:@text, +"w")
p k.instance_variable_set(:@text, +"y").upcase
k.bump
p k.text

# a value nobody reads, and an assignment that only reads the slot back
k.instance_variable_set(:@text, +"z")
p k.text
n = (k.instance_variable_set(:@text, +"abc")).length
p n
