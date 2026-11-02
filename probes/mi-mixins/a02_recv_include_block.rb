module M
  def hi = "M"
end
class K; end
[1].each { K.include(M) }
p K.new.hi
