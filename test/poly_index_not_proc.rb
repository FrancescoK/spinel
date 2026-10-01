# `env[k]` on a boxed value is a call only when the value can be a proc.
# Here env is a Hash or nil (so it is boxed), and only a lambda elsewhere
# appends to its argument: the lookups are plain reads.
class Refusal < StandardError; end

def read_env(line)
  return nil if line.empty?
  raise Refusal if line == "bad"
  { "PATH_INFO" => line, "QUERY_STRING" => "" }
end

def next_env(line)
  read_env(line)
rescue Refusal
  nil
end

class App
  def call(env) = %w[PATH_INFO QUERY_STRING X].map { |k| "#{k}=#{env[k]}" }
end

def respond(app, env) = app.call(env)

app = App.new
["/a", "", "bad", "/b"].each do |line|
  env = next_env(line)
  p env ? respond(app, env) : nil
end

pick = ->(on) { on ? { "k" => "v" } : nil }
h = pick.(true)
%w[k z].each { |k| p h[k] } if h

out = []
stream = ->(s) { s << "!" }
stream.call(out)
p out
