# A program class whose own `is_a?` answers other than true or false,
# aliased as `kind_of?`, types every poly receiver's `kind_of?(Const)` as
# a box: the runtime class test on a receiver of another class is boxed
# for it, where the C handed an int to an sp_RbVal.
class Doc
  def +(n)
    "doc+#{n}"
  end
end

class Memo < Doc
end

class Duration
  def is_a?(klass)
    klass == Integer ? :yes : nil
  end
  alias :kind_of? :is_a?
end

def incorporate(time, offset)
  if offset.zero?
    time
  elsif time.kind_of?(Doc)
    time + offset
  else
    "other"
  end
end

[Doc.new, Memo.new, 3].each do |t|
  p incorporate(t, 0).class
  p incorporate(t, 1)
end
p Duration.new.kind_of?(Integer)
p Duration.new.kind_of?(String)
