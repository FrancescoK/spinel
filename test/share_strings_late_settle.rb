# Sharing that only shows once a proc's body is typed after the fixpoint
# still reaches every holder: the rule is reapplied in the late phases.
def read_env(line)
  return nil if line.empty?
  { "PATH_INFO" => line }
end
class App
  def call(env) = %w[PATH_INFO X].map { |k| "#{k}=#{env[k]}" }
end
app = App.new
["/a", ""].each do |line|
  env = read_env(line)
  p env ? app.call(env) : nil
end
out = []
stream = ->(s) { s << "!" }
stream.call(out)
p out
