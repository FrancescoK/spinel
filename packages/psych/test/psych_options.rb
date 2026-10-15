# The loading entry points and their keywords: permitted classes and
# symbols, aliases, symbolize_names, fallback, strict_integer,
# parse_symbols, and the file readers.
require "psych"
require "tmpdir"

p Psych.safe_load("a: :b\n:c: 1\n", permitted_classes: [Symbol])
p Psych.safe_load("a: :b\n", permitted_classes: [Symbol], permitted_symbols: [:b])
begin
  Psych.safe_load("a: :c\n", permitted_classes: [Symbol], permitted_symbols: [:b])
rescue Psych::DisallowedClass => e
  puts e.message
end
r = Psych.safe_load("a: &x [1]\nb: *x\n", aliases: true)
p r, r["a"].equal?(r["b"])
p Psych.safe_load("a: 1\nb: {c: 2}\nd: [{e: 3}]\n", symbolize_names: true)
p Psych.safe_load("", fallback: {})
p Psych.safe_load("# only a comment\n", fallback: [])
p Psych.safe_load("---\n", fallback: 1)
p Psych.load("a: :b")
p Psych.unsafe_load("a: &x 1\nb: *x\nc: :d\n")
p Psych.safe_load("1,000", strict_integer: true), Psych.safe_load("1_000", strict_integer: true)
p Psych.safe_load("a: :b", permitted_classes: [Symbol], parse_symbols: false)

path = File.join(Dir.tmpdir, "sp_psych_options_#{Process.pid}.yml")
begin
  File.write(path, "\uFEFFprojects:\n  one:\n    path: \"/tmp/one\"\npeers: {}\n")
  p Psych.safe_load_file(path)
  p Psych.load_file(path, symbolize_names: true)
  File.write(path, "")
  p Psych.safe_load_file(path), Psych.load_file(path, fallback: { "empty" => true })
  File.write(path, "a: [1\n")
  begin
    Psych.safe_load_file(path)
  rescue Psych::SyntaxError => e
    puts e.message.sub(path, "PATH")
  end
ensure
  File.delete(path) if File.exist?(path)
end
begin
  Psych.safe_load_file(path)
rescue Errno::ENOENT => e
  puts e.class
end
