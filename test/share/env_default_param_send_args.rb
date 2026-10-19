# A computed send that hands the method a Hash: the method's parameter is
# the caller's Hash, whose String is shared and changed in place.
class Prox
  def bang(env = ENV)
    env["k"] << "!"
    nil
  end
end

s = +"abc"
o = [Prox.new, 1][0]
o.public_send(("ba" + "ng").to_sym, {"k" => s})
p s
