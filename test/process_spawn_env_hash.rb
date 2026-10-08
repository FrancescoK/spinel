# Process.spawn with an environment Hash before the command. The child gets
# this process's environment with each String value set and each nil value
# removed; its PATH is the one the command is searched on. A Hash that comes
# through a splat or through Open3 is read the same way.
require "open3"
require "tmpdir"

def child_env(env, *names)
  r, w = IO.pipe
  script = names.map { |n| "printf '%s=%s|' #{n} \"${#{n}-unset}\"" }.join("; ")
  pid = Process.spawn(env, "sh", "-c", script, out: w)
  w.close
  Process.wait(pid)
  out = r.read
  r.close
  out
end

ENV["SPAWN_ENV_KEPT"] = "parent"
ENV["SPAWN_ENV_DROPPED"] = "parent"

puts child_env({ "SPAWN_ENV_SET" => "child" }, "SPAWN_ENV_SET", "SPAWN_ENV_KEPT")
puts child_env({ "SPAWN_ENV_DROPPED" => nil, "SPAWN_ENV_KEPT" => "child" }, "SPAWN_ENV_DROPPED", "SPAWN_ENV_KEPT")
puts child_env({}, "SPAWN_ENV_DROPPED")
p ENV["SPAWN_ENV_DROPPED"]

args = [{ "SPAWN_ENV_SET" => "splat" }, "sh", "-c", "printf %s \"$SPAWN_ENV_SET\""]
r, w = IO.pipe
pid = Process.spawn(*args, out: w)
w.close
Process.wait(pid)
p r.read

out, _err, status = Open3.capture3({ "SPAWN_ENV_SET" => "open3" }, "sh", "-c", "printf %s \"$SPAWN_ENV_SET\"")
p [out, status.success?]

begin
  Process.spawn({ "PATH" => File.join(Dir.tmpdir, "spawn_env_no_such_dir") }, "sh", "-c", "true")
rescue SystemCallError => e
  p e.class
end

[[{ "SPAWN=ENV" => "x" }, "true"], [{ "SPAWN_ENV" => 1 }, "true"], [{ "SPAWN_ENV" => "x" }]].each do |bad|
  begin
    Process.spawn(*bad)
  rescue ArgumentError, TypeError => e
    p e.class
  end
end
