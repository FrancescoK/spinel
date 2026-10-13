# Two class sets that share members merge into one set of their distinct
# classes (#8530): ten and ten with six in common is fourteen, within the
# limit, and a call on a value of either side still reaches every class.
class C1
  def tag = "c1"
end

class C2
  def tag = "c2"
end

class C3
  def tag = "c3"
end

class C4
  def tag = "c4"
end

class C5
  def tag = "c5"
end

class C6
  def tag = "c6"
end

class C7
  def tag = "c7"
end

class C8
  def tag = "c8"
end

class C9
  def tag = "c9"
end

class C10
  def tag = "c10"
end

class C11
  def tag = "c11"
end

class C12
  def tag = "c12"
end

class C13
  def tag = "c13"
end

class C14
  def tag = "c14"
end

def left = [C1.new, C2.new, C3.new, C4.new, C5.new, C6.new, C7.new, C8.new, C9.new, C10.new]
def right = [C5.new, C6.new, C7.new, C8.new, C9.new, C10.new, C11.new, C12.new, C13.new, C14.new]

def pick(flag) = flag ? left : right

p pick(true).map { |o| o.tag }
p pick(false).map { |o| o.tag }
p pick(ARGV.empty?)[0].tag
