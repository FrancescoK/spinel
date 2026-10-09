# A module method builds an Array of one class into an ivar, and the class
# that includes the module reads it. The includer's copy of the ivar narrows
# to that class's object array; the write, merged in again from the module's
# own scope as the general Array, widened it back every round, and the
# fixpoint ran to its round cap.
class Window
  def peek = 1
end

module Pages
  def build_pages
    @windows = [Window.new, Window.new]
  end
end

class Bus
  include Pages
  def initialize = build_pages
  def read(i) = @windows[i]
end

p Bus.new.read(0).peek
