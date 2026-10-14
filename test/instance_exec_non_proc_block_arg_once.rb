LOG = []

class Box
  def rx = (LOG << :recv; "r")
  def ax = (LOG << :arg; 5)

  def go_local
    b = 7
    rx.instance_exec(ax, &b)
  rescue StandardError
    :raised
  end
end

class Holder
  def initialize(&b) = @b = b
  def run(o) = o.instance_exec(&@b)
end

p Holder.new { self.class }.run(Object.new)
p Box.new.go_local
p LOG
