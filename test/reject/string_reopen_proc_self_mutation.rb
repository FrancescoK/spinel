# String self needs the sharing build when its block mutates it.
# spinel: reject-share
# spinel: reject-self-mutation
class String
  def block_mutation(&b)
    b.call(self)
    +"fresh"
  end
end
s = +"a"
p s.block_mutation { |x| x << "!" }
p s
