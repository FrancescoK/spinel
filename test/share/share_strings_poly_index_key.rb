# Flag-only: without the flag (as on master) the boxed lookup with a shared key answers nil.
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
# a Proc's, a curried Proc's or a user object's [] on a boxed receiver takes
# the String itself, not its contents
class Grow
  def [](s) = (s << "+"; s.size)
end
pr = [proc { |t| t << "?" }, ->(a, b) { a << b }.curry, Grow.new, 1]
s = +"q"
pr[0][s]
pr[1][s]["!"]
pr[2][s]
p s
