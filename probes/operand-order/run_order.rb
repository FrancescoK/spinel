# Runs the programs gen_order.rb wrote: CRuby (the oracle, frozen string
# literals) against spinel, case by case.
#
#   ruby run_order.rb GENDIR SPINEL [--jobs 2] [--label master] [--env K=V]
#
# A program spinel cannot compile is split in halves down to the case that
# carries the failure (CERR). A program that crashes is split the same way.
# Writes GENDIR/<label>.results.tsv: id, status (ok / WRONG / CERR / CRASH /
# MISSING), expected line, observed line. Binaries are deleted as they go.

require "open3"
require "timeout"

gdir, spinel = ARGV.shift(2)
jobs = 2
label = "run"
env = {}
while (a = ARGV.shift)
  case a
  when "--jobs" then jobs = Integer(ARGV.shift)
  when "--label" then label = ARGV.shift
  when "--env" then k, v = ARGV.shift.split("=", 2); env[k] = v
  end
end

PRE = File.read(File.join(gdir, "prelude.rb"))
SRC = {}
File.foreach(File.join(gdir, "case_src.tsv")) { |l| id, b = l.chomp.split("\t"); SRC[id.to_i] = b.unpack1("m0") }
TMP = File.join(gdir, "tmp_#{label}")
Dir.mkdir(TMP) unless Dir.exist?(TMP)

def lines_by_id(out)
  h = {}
  out.each_line { |l| h[$1.to_i] = l.chomp if l =~ /\A\[(\d+),/ }
  h
end

def run_cmd(env, cmd, timeout)
  o = e = ""; st = nil
  Open3.popen3(env, *cmd) do |_i, so, se, w|
    begin
      Timeout.timeout(timeout) { o = so.read; e = se.read; st = w.value }
    rescue Timeout::Error
      Process.kill("KILL", w.pid) rescue nil
      st = :timeout
    end
  end
  [o, e, st]
end

# results for the case ids `ids`: id => [status, observed]
def run_set(ids, tag, spinel, env)
  src = File.join(TMP, "#{tag}.rb")
  bin = File.join(TMP, tag)
  File.write(src, PRE + ids.map { |i| SRC[i] }.join)
  _o, e, st = run_cmd(env, [spinel, src, "-O", "0", "-o", bin], 300)
  res = {}
  if st == :timeout || !st.success? || !File.exist?(bin)
    if ids.size == 1
      msg = (e.lines.grep(/error|unsupported|refus/i).first || e.lines.last || st.to_s).strip[0, 200]
      res[ids[0]] = ["CERR", msg]
    else
      h = ids.size / 2
      res.merge!(run_set(ids[0, h], tag + "a", spinel, env))
      res.merge!(run_set(ids[h..], tag + "b", spinel, env))
    end
  else
    o, e2, st2 = run_cmd(env, [bin], 60)
    got = lines_by_id(o)
    crashed = st2 == :timeout || !st2.success?
    if crashed && ids.size > 1 && got.size < ids.size
      File.delete(bin) rescue nil
      h = ids.size / 2
      res.merge!(run_set(ids[0, h], tag + "a", spinel, env))
      res.merge!(run_set(ids[h..], tag + "b", spinel, env))
      return res
    end
    ids.each do |i|
      if got[i] then res[i] = ["RAN", got[i]]
      else res[i] = [crashed ? "CRASH" : "MISSING", (e2.lines.last || st2.to_s).to_s.strip[0, 200]]
      end
    end
  end
  File.delete(src) rescue nil
  File.delete(bin) rescue nil
  File.delete(bin + ".c") rescue nil
  res
end

progs = Dir.glob(File.join(gdir, "b_*.rb")).sort
q = Queue.new
progs.each { |p| q << p }
out = {}
mu = Mutex.new
t0 = Time.now
ths = Array.new(jobs) do
  Thread.new do
    while (p = (q.pop(true) rescue nil))
      exp_o, _e, _s = run_cmd({ "LC_ALL" => "en_US.UTF-8" }, ["ruby", "--enable-frozen-string-literal", p], 60)
      exp = lines_by_id(exp_o)
      ids = File.read(p).scan(/^def c_(\d+)$/).flatten.map(&:to_i)
      res = run_set(ids, File.basename(p, ".rb"), spinel, env)
      mu.synchronize do
        ids.each do |i|
          st, obs = res[i]
          st = obs == exp[i] ? "ok" : "WRONG" if st == "RAN"
          out[i] = [st, exp[i].to_s, obs.to_s]
        end
        warn "#{File.basename(p)} done (#{out.size} cases, #{(Time.now - t0).round}s)"
      end
    end
  end
end
ths.each(&:join)
File.open(File.join(gdir, "#{label}.results.tsv"), "w") do |f|
  out.keys.sort.each { |i| f.puts [i, *out[i]].join("\t") }
end
tally = out.values.map(&:first).tally
warn "#{label}: #{tally.inspect} in #{(Time.now - t0).round}s"
