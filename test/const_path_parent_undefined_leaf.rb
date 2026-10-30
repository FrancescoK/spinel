# A path whose parent is unset and whose leaf is defined nowhere raises the
# parent's NameError first, wherever the read lands: a scalar slot, an
# operand, a String, an element.
class Target
end
$assigned = false
def report(error)
  puts($assigned ? error.message.include?("::Missing") : error.message)
end
module Outer
  def self.store
    x = 1
    x = Outer::HOLDER::Missing
    p x
  rescue NameError => e
    report(e)
  end
  def self.add
    p 1 + Outer::HOLDER::Missing
  rescue NameError => e
    report(e)
  end
  def self.text
    s = 'a'
    s = Outer::HOLDER::Missing
    p s
  rescue NameError => e
    report(e)
  end
  def self.float
    x = 1.5
    x = Outer::HOLDER::Missing
    p x
  rescue NameError => e
    report(e)
  end
  def self.element
    p [1, Outer::HOLDER::Missing].size
  rescue NameError => e
    report(e)
  end
  def self.argument
    p [3].push(Outer::HOLDER::Missing).size
  rescue NameError => e
    report(e)
  end
  def self.deep
    x = 1
    x = Outer::HOLDER::Missing::Deeper
    p x
  rescue NameError => e
    report(e)
  end
  def self.conditional
    x = 1
    x = Outer::HOLDER::Missing if x == 1
    p x
  rescue NameError => e
    report(e)
  end
  def self.rescued
    begin
      raise 'q'
    rescue Outer::HOLDER::Missing::Thing
      puts 'rescued'
    end
  rescue NameError => e
    report(e)
  end
end
def run
  Outer.store
  Outer.add
  Outer.text
  Outer.float
  Outer.element
  Outer.argument
  Outer.deep
  Outer.conditional
  Outer.rescued
end
run
module Outer
  HOLDER = (puts 'assigned'; Target)
end
$assigned = true
run
