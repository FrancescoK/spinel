class OwnClone
  def clone(freeze: nil) = "own #{freeze}"
end
fz = "custom"
p OwnClone.new.clone(freeze: fz)
