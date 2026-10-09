# ENV[k] op= v, ||= and &&= read the variable, combine and store, and
# answer what they store, as CRuby's ENV#[] and ENV#[]= make them. A key
# with side effects is evaluated once; a missing variable reads nil.
pre = "SPINEL_ENV_OPW_"
k = pre + "A"
ENV.delete(k)
p(ENV[k] ||= "one")
p(ENV[k] ||= "two")
p(ENV[k] += "+")
p(ENV[k] &&= "three")
ENV.delete(k)
p(ENV[k] &&= "four")
p ENV.key?(k)
ENV[k] = "a"
ENV[k] += "b"
x = ENV[k] *= 2
p x, ENV[k], ENV[k].frozen?
$calls = 0
def key_of(name)
  $calls += 1
  name
end
ENV[key_of(k)] += "!"
ENV[key_of(pre + "B")] ||= "b"
ENV[key_of(pre + "B")] &&= "bb"
p $calls, ENV[k], ENV[pre + "B"]
ENV.delete(k)
begin
  ENV[k] += "z"
rescue NoMethodError => e
  p e.class
end
p ENV.key?(k)
begin
  ENV[k] ||= "v\0w"
rescue ArgumentError => e
  p e.message
end
p ENV.key?(k)
[1, 2].each { |i| ENV["#{pre}C"] ||= i.to_s; ENV["#{pre}C"] += i.to_s }
p ENV[pre + "C"]
%w[A B C].each { |s| ENV.delete(pre + s) }
p ENV.keys.select { |name| name.start_with?(pre) }
