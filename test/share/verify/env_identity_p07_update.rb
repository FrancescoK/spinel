ENV["RVENV_U1"] = "a"
ENV.update("RVENV_U1" => "b", "RVENV_U2" => "c")
p ENV["RVENV_U1"], ENV["RVENV_U2"]
ENV.merge!("RVENV_U1" => "z") { |k, o, n| o + n }
p ENV["RVENV_U1"]
ENV.delete("RVENV_U1"); ENV.delete("RVENV_U2")
