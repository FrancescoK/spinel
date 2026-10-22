# A super with a literal block, spliced into its caller: from a prepended
# class's own method, from an included module's copy, and in a method given
# a proc with `&`, whose yields run the proc while the parent's yields run
# the super's block.
module Tens
  def each_part
    super { |v| yield v * 10 }
  end
end

class Base
  def each_part
    yield 1
    yield 2
  end
end

class Prepended < Base
  prepend Tens
  def each_part
    super { |v| yield v + 1 }
  end
end

Prepended.new.each_part { |v| p v }
seen = []
Prepended.new.each_part { |v| seen << v }
p seen

module Hundreds
  def walk
    super { |v| yield v * 100 }
  end
end

class Walker
  def walk
    yield 3
  end
end

class Included < Walker
  include Hundreds
end
Included.new.walk { |v| p v }

class Scanner
  def scan
    yield 4
    :done
  end
end

module Less
  def scan
    super { |v| yield v - 1 }
  end
end

class Doubled < Scanner
  prepend Less
  def scan
    super { |v| yield v * 2 }
  end
end
p(Doubled.new.scan { |v| p v })

class Plus < Base
  def each_part
    super { |v| yield v + 1 }
  end
end

class Times < Plus
  def each_part
    super { |v| yield v * 10 }
  end
end

pr = proc { |v| p [:proc, v] }
Plus.new.each_part(&pr)
Times.new.each_part(&pr)
Prepended.new.each_part(&pr)
def forward(&b) = Times.new.each_part(&b)
forward { |v| p [:blk, v] }
