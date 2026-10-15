# `require "yaml"` is Psych under its other name. The shapes a program keeps
# in YAML files -- nested settings, a config with Integer and nil values, a
# list of records -- written with YAML.dump and read back with
# YAML.safe_load_file come back equal, and the text is CRuby's.
require "yaml"
require "tmpdir"

p YAML.equal?(Psych)
stores = [
  { "sites" => { "blog" => { "root" => "/srv/www/blog" }, "2024" => { "root" => "/x" } },
    "hosts" => { "db.example.com" => "AB12CD3-EF45GH6-IJ78KLM" } },
  { "name" => "worker", "retention_days" => 30, "paused" => false, "note" => nil, "since" => "2026-10-09T07:00:00Z" },
  [{ "name" => "a b", "target" => "/home/u/.ssh/id", "archived" => true }, { "name" => "yes", "target" => "~" }],
  {}
]
path = File.join(Dir.tmpdir, "sp_yaml_store_#{Process.pid}.yml")
begin
  stores.each do |s|
    File.write(path, YAML.dump(s))
    print File.read(path)
    back = YAML.safe_load_file(path, permitted_classes: [Symbol], aliases: true)
    p back == s
  end
ensure
  File.delete(path) if File.exist?(path)
end
