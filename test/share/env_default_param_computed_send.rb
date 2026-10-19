# A parameter defaulting to ENV, read through a method a computed
# public_send reaches on a boxed receiver, shares no String: ENV answers a
# new one per read.
class Prox
  def find(env = ENV) = env["SPINEL_NO_SUCH_VAR_A"]
  def has(env = ENV) = env.fetch("SPINEL_NO_SUCH_VAR_B", "dflt")
  def via_local(env = ENV)
    v = env["SPINEL_NO_SUCH_VAR_C"] || "none"
    v + "!"
  end
end

o = [Prox.new, "hi"][0]
p o.public_send(("fi" + "nd").to_sym)
p o.send(("h" + "as").to_sym)
p o.public_send(("via_" + "local").to_sym)
