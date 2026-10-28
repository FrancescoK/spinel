# spinel: reject-subclass: a define_method under a condition only the run time decides
module Box
  D = Data.define(:a) do
    if ENV["NOPE"]
      define_method(:hi) { 1 }
    end
  end
end
p Box::D.new(a: 1).respond_to?(:hi)
