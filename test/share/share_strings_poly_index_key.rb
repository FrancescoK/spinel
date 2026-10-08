# A boxed lookup whose key is a String the rule shares reads the key's
# current contents.
env = { "PATH_INFO" => "/a" }
keys = %w[PATH_INFO X].map { |k| +k }
k0 = keys[0]
mutate = ->(s) { s << "" }
mutate.call(+"z")
p keys.map { |k| "#{k}=#{env[k]}" }
box = [env, 1][0]
p box[k0], box[keys[1]]
