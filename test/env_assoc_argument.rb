# ENV.assoc keeps the argument as the pair's key; a snapshot may not copy it.
key = +"SPINEL_SHARE_ENV_ASSOC"
ENV[key] = "value"
pair = ENV.assoc(key)
pair[0] << "!"
p key, pair
ENV.delete("SPINEL_SHARE_ENV_ASSOC")
