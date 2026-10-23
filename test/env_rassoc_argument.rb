# ENV.rassoc keeps the argument as the pair's value.
value = +"SPINEL_SHARE_ENV_RASSOC_VALUE"
ENV["SPINEL_SHARE_ENV_RASSOC"] = value
pair = ENV.rassoc(value)
pair[1] << "!"
p value, pair
ENV.delete("SPINEL_SHARE_ENV_RASSOC")
