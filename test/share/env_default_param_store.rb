# A parameter defaulting to ENV that the method stores into: a later read
# can answer what was stored, so the reads are not apart from the store.
# (ENV copies what it stores and answers frozen Strings, so the String
# stored stays unchanged.)
class Store
  def each_value_after_store(env = ENV)
    s = +"abc"
    env["SPINEL_ENV_DEFAULT_STORE_A"] = s
    env.each_value { |v| v << "?" rescue nil }
    s
  end

  def values_after_update(env = ENV)
    s = +"abc"
    env.update("SPINEL_ENV_DEFAULT_STORE_B" => s)
    env.values.each { |v| v.upcase! rescue nil }
    s
  end
end

p Store.new.each_value_after_store
p Store.new.values_after_update
o = [Store.new, 1][0]
p o.public_send(("each_value_" + "after_store").to_sym)
