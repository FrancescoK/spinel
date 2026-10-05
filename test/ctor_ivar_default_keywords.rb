# Keywords do not fill a positional optional in initialize. Its default
# reads the newly allocated receiver, including on a call that rejects keys.
class KeywordDefault
  attr_reader :value
  def initialize(x = @seed, k: 1)
    @value = [x, k]
  end
end
p KeywordDefault.new(k: 2).value
p KeywordDefault.new(3, k: 4).value
p KeywordDefault.new(**{}).value
p KeywordDefault.new(**{k: 5}).value
klass = KeywordDefault
p klass.new(k: 6).value

class RestDefault
  attr_reader :value
  def initialize(a, b, x = @seed, *rest, **nil, &block)
    @value = [a, b, x, rest, block ? block.call : nil]
  end
end
p RestDefault.new(1, 2, **{}) { :block }.value
p RestDefault.new(1, 2, 3, 4, **{}).value
begin
  RestDefault.new(1, 2, k: 3)
rescue ArgumentError => e
  puts e.message
end
begin
  RestDefault.new(*[1, 2], 3, 4, **{"s" => 5}, k: 6)
rescue ArgumentError => e
  puts e.message
end

class LeadingDefault
  attr_reader :value
  def initialize(x = seed, last, **keys)
    @value = [x, last, keys]
  end
  def seed = 7
end
p LeadingDefault.new(8, k: 9).value
p LeadingDefault.new(10, 11, k: 12).value
p LeadingDefault.new(*[13], **{}).value

class InheritedDefault < KeywordDefault
end
p InheritedDefault.new(k: 14).value

class ErrorDefault < StandardError
  attr_reader :value
  def initialize(x = @seed, k: 1)
    @value = [x, k]
    super("error")
  end
end
p ErrorDefault.new(k: 15).value
p ErrorDefault.new(16, k: 17).value
