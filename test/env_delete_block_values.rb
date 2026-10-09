# spinel: share
# spinel: gc-minor
# A missing-key block returns its Ruby value without String conversion.
key = "SPINEL_ENV_DELETE_VALUES_72B8"
ENV.delete(key)
p ENV.delete(key) { 8 }
p ENV.delete(key) { false }
p ENV.delete(key) { nil }
p ENV.delete(key) { :missing }
p ENV.delete(key) { [1, 2] }
p ENV.delete(key) { {"a" => 3} }
p ENV.delete(key) { }
p ENV.delete(key) { |k| k.length }
ENV[key] = "present"
p ENV.delete(key) { 8 }
ENV[key] = "present"
p ENV.delete(key) { +"unused" }.frozen?
ENV.delete(key)
