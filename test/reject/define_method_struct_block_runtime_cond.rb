# spinel: reject-subclass: a define_method under a condition only the run time decides
S = Struct.new(:a) do
  if ENV["NOPE"]
    define_method(:x) { 1 }
  end
end
p S.new(1).respond_to?(:x)
