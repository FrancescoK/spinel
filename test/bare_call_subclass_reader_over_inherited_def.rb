# A receiverless call to a subclass attr_reader that overrides a superclass
# def was typed by the def's return while the emitted code read the
# reader's ivar, and the C did not compile (#7303).
class Terminal
  def seek_to = 0.0
  def label = "none"
end

class Window < Terminal
  attr_reader :seek_to, :label

  def initialize(length)
    @seek_to = 0.0
    @length = length
    @label = length
  end

  def click(left)
    @seek_to = (left / 80.0) * @length
  end

  def follow = [seek_to]
  def tag = [label]
end

# a def nearer than the reader still answers
class Pane < Window
  def seek_to = -1.0
  def peek = seek_to
end

w = Window.new(ARGV.empty? ? 100 : "x")
w.click(40)
p w.follow
p w.tag
pa = Pane.new(10)
p pa.peek
p pa.follow
