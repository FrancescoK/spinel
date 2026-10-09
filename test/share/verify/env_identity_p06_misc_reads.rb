ENV["RVENV_M1"] = "v1"
ENV["RVENV_M2"] = "v2"
p ENV.key("v1")
p ENV.assoc("RVENV_M1")
p ENV.rassoc("v2")
p ENV.values_at("RVENV_M1", "RVENV_M2", "RVENV_NOPE")
h = ENV.to_h
p h["RVENV_M1"]
p ENV.slice("RVENV_M1", "RVENV_M2")
p ENV.select { |k, v| k.start_with?("RVENV_M") }.sort
p ENV.filter_map { |k, v| v if k.start_with?("RVENV_M") }.sort
p ENV.key?("RVENV_M1"), ENV.include?("RVENV_NOPE")
ENV.delete("RVENV_M1"); ENV.delete("RVENV_M2")
