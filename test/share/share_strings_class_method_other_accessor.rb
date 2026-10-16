# A class method's receiverless `name` is Module#name of its Class, a new
# String, also when another class has a singleton accessor `name`: that
# accessor is not self's method there. Kept beside a String changed
# through another name and handed to an exception, it compiles and answers
# the class's name. A class method of the class that has the accessor
# reads the accessor.
$all = []
class NotFound < StandardError
  attr_reader :model
  def initialize(msg, model)
    super(msg)
    @model = model
    $all << model
  end
end
class Rec
  attr_reader :name
  def initialize(n) = @name = n
  def self.find(id)
    raise NotFound.new("no #{name} #{id}", name) if id.nil?
    id
  end
end
class Other
  class << self
    attr_accessor :label
    attr_reader :name
  end
  def self.show = label
end
Other.label = +"other"
b = +"buf"
$all << b
b << "!"
r = Rec.new(b)
begin
  Rec.find(ARGV.size > 0 ? 1 : nil)
rescue NotFound => e
  p e.message, e.model
end
p r.name, Other.show, $all
