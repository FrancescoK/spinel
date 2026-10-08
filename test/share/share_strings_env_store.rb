# spinel: gc-minor
# ENV stores a copy, but both store spellings return their value argument.
# The default build may copy between names; the flag preserves identity.
x = +"ab"
r = ENV.store("SPINEL_SHARE_ENV_STORE", x)
r << "!"
p x, r, ENV["SPINEL_SHARE_ENV_STORE"]
ENV.delete("SPINEL_SHARE_ENV_STORE")

x = +"cd"
r = ENV.[]=("SPINEL_SHARE_ENV_ASET", x)
x << "?"
p x, r, ENV["SPINEL_SHARE_ENV_ASET"]
ENV.delete("SPINEL_SHARE_ENV_ASET")

x = +"ef"
r = (ENV["SPINEL_SHARE_ENV_ASSIGN"] = x)
r << "+"
p x, r, ENV["SPINEL_SHARE_ENV_ASSIGN"]
ENV.delete("SPINEL_SHARE_ENV_ASSIGN")

x = +"gh"
ENV.store("SPINEL_SHARE_ENV_CHAIN", x) << "!"
p x, ENV["SPINEL_SHARE_ENV_CHAIN"]
ENV.delete("SPINEL_SHARE_ENV_CHAIN")

def env_order_key(log)
  log << "key;"
  +"SPINEL_SHARE_ENV_ORDER"
end

def env_order_value(log, value)
  log << "value;"
  GC.start
  value
end

log = +""
x = +"ij"
r = ENV.store(env_order_key(log), env_order_value(log, x))
r << "?"
p log, x, r, ENV["SPINEL_SHARE_ENV_ORDER"]
ENV.delete("SPINEL_SHARE_ENV_ORDER")

x = +"kl"
boxed = [ENV.store("SPINEL_SHARE_ENV_BOX", x), 7][0]
boxed << "!"
p x, boxed, ENV["SPINEL_SHARE_ENV_BOX"]
ENV.delete("SPINEL_SHARE_ENV_BOX")

frozen = "frozen"
r = ENV.store("SPINEL_SHARE_ENV_FROZEN", frozen)
begin
  r << "!"
rescue FrozenError
  puts "frozen"
end
p frozen, ENV["SPINEL_SHARE_ENV_FROZEN"]
p ENV.store("SPINEL_SHARE_ENV_FROZEN", nil)
p ENV["SPINEL_SHARE_ENV_FROZEN"]
ENV.delete("SPINEL_SHARE_ENV_FROZEN")
