# ENV flowing as a value (a Hash value, an argument, a parameter default, a
# local, an ivar, an Array element) reads the environment like ENV itself.

def lookup(env, k) = env[k]
def default_env(env = ENV) = env["SPX_ENV_VALUE"]

class Holder
  def initialize; @env = ENV; end
  def get(k) = @env.fetch(k, "none")
end

ENV["SPX_ENV_VALUE"] = "set"

# the access-log params shape: a mixed Hash with ENV under "e"
params = Hash.new("")
params["e"] = ENV
params["m"] = "GET"
p params["e"]["SPX_ENV_VALUE"]
p params["e"]["SPX_ENV_MISSING"]
p params["m"]

e = ENV
p e["SPX_ENV_VALUE"]
p e.key?("SPX_ENV_VALUE")
p lookup(ENV, "SPX_ENV_VALUE")
p default_env
p Holder.new.get("SPX_ENV_VALUE"), Holder.new.get("SPX_ENV_MISSING")
p [ENV].first["SPX_ENV_VALUE"]
p({ "e" => ENV }["e"].select { |k, _| k == "SPX_ENV_VALUE" })
