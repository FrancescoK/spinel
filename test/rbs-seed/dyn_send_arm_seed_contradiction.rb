# A runtime-name send's arms cover every method the program names, so an arm
# for a seeded method can pass an argument the seed contradicts. That arm runs
# only when the name selects it: the program builds, the other arms run, and
# the contradicted one raises TypeError instead of reinterpreting the value
# (#6672). An ordinary call site with the same contradiction is still refused
# (seed_contradiction_arg.rb).
# spinel: rbs-seed-check
class DynArmSeedReport
  def read_file(path)
    path.length
  end

  def summarize(opts)
    opts[:count] * 2
  end

  def run(name, h)
    method(name).call(h)
  end

  def run_send(name, h)
    send(name, h)
  end
end

r = DynArmSeedReport.new
puts r.read_file("abc")
puts r.run(ARGV.fetch(0, "summarize"), { count: 21 })
puts r.run_send(ARGV.fetch(1, "summarize"), { count: 5 })
puts r.respond_to?(:read_file)
begin
  r.run(ARGV.fetch(2, "read_file"), { count: 1 })
  puts "not raised"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
begin
  r.run_send(ARGV.fetch(2, "read_file"), { count: 1 })
  puts "not raised"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
