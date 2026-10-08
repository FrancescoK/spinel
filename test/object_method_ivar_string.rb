# spinel: gc-minor
# Reading a mutable String slot through Object answers its String value,
# not the slot's internal storage type. No cross-name identity is observed.
class Object
  def text = @text
end
class MutableText
  def initialize = (@text = +"text")
  def append = (@text << "!")
end
t = MutableText.new
t.append
p t.text, 5.text
