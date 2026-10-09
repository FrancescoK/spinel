class K
  class << self
    attr_accessor :v
  end
end
s = +"abc"
K.v = s
K.v << "!"
p s
